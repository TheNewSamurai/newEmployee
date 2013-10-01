require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'Date'

class EmployeeController < Rho::RhoController
  include BrowserHelper

  # GET /Employee
  def index
    @employee = Employee.find(:all)
    render :back => '/app'
  end

  # GET /Employee/{1}
  def show
    #Temporary check TO BE IMPROVED and Modulized
    if @params['id'].nil?
      @employee = Employee.find($holdModelID)
    else
      @employee = Employee.find(@params['id'])
    end

    if @employee
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /Employee/new
  def new
    @employee = Employee.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Employee/{1}/edit
  def edit
    @employee = Employee.find(@params['id'])
    if @employee
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Employee/create
  #Flags for Validation with binary flags firstName, lastName, phone, startDate, endDate, status.
  #EX: startDate and endDate are in incorrect format.
  def create
    puts @params
    # Check if the fields are valid or not
    @invalidFields = []
    @params['employee'].each do |key, value|
      puts key
      #Check for empty value
      if value.empty?
        puts "EMPTY PARAM"
        @invalidFields << {key => value}
        #WebView.executeJavascript('invalidForm();')
        #break
      end
      case key
      when "firstName", "lastName"
        # Check to see if the form value is valid otherwise return error.
        # Regular expression for Digits and Whitespace only
        if (value =~ /[\d\W]+/).nil?
          puts "#{value} OK"
        else
          @invalidFields << {key => value}
        end
      when "phone"
        # Valid only with number between 10 - 12 digits
        # Regular expression for Numbers only
        #if (key =~ /[\D]+/).nil?
        if (value =~ /(?:\+?|\b)[0-9]{10,12}\b/) == 0
          puts "#{value} OK"
        else
          @invalidFields << {key => value}
        end
      when "startDate"
        begin
          d = Date.parse(value)
        rescue Exception => e
          @invalidFields << {key => value}
          puts "invalid Start Date"
        end
      when "endDate"
        begin
          d = Date.parse(value)
        rescue Exception => e
          @invalidFields << {key => value}
          puts "invalid End Date"
        end
      when "status"
        puts "Status Check"
      else
        puts "I shouldn't be SEEN!"
      end        
      puts @invalidFields
    end

    if @invalidFields.empty?
      @employee = Employee.create(@params['employee'])
      $holdModelID = @employee.object
      redirect :action => :preparePic
    else
      #WebView.executeJavascript('invalidForm(#{@invalidFields});')
      WebView.executeJavascript('invalidForm();')
      redirect :action => :new
    end
  end

  # POST /Employee/{1}/update
  def update
    @employee = Employee.find(@params['id'])
    @employee.update_attributes(@params['employee']) if @employee
    redirect :action => :index
  end

  # POST /Employee/{1}/delete
  def delete
    @employee = Employee.find(@params['id'])
    @employee.destroy if @employee
    redirect :action => :index  
  end
  
### Camera Related Methods ###
  
  def load_camera
    puts "!!! Starting Camera !!!"
    #Rho::Camera.takePicture({}, :camera_callback)          API when Camera implementation is fixed
    Camera::take_picture(url_for(:action => :camera_callback))#, :id => $holdModelID))
  end

  def camera_callback
    #@employee = Employee.find(@params['id'])
    @employee = Employee.find($holdModelID)
    
    #Save the image to the New Employee/Guest
    if @params['status'] == 'ok'
      puts "Camera Picture Successful!"
      $imageHolder = @params['image_uri']
      #puts Rho::Application.expandDatabaseBlobFilePath($imageHolder)
      #Rho::WebView.navigate(url_for(:action => :preview_image)) #, :id => @employee.object))
      Rho::WebView.navigate(url_for(:action => :preview_image, :acceptImg => @params['image_uri']))
      #redirect :action => :previewPic
    elsif @params['status'] == 'cancel'
      Rho::Notification.showPopup({
        :message => "Image Taking Canceled",
        :title => "Canceled",
        :icon => "",
        :buttons => [{:id => "OK", :title => "OK"}]
        })
        #:callback => :) #TODO - ADD CAllBACK
    else
      Rho::Notification.showPopup({
        :message => "Image Taking Error #{@params['message']}",
        :title => "Error",
        :icon => "",
        :buttons => [{:id => "OK", :title => "OK"}]
        })
        #:callback => :) #TODO - ADD CAllBACK
    end
  end

### Image saving and displaying

  def preview_image
    #@employee = Employee.find(@params['id'])
    render :action => :previewPic
  end

  def assign_image
    #TO BE Optimized by finding first match
    @employee = Employee.find($holdModelID)
    puts @employee
    @employee.update_attributes({:image => $imageHolder})
    puts @employee

    #Clear globals for collection and open listing.
    clear_camera_vars
    redirect :action => :index
  end

  def clear_camera_vars
    $holdModelID = nil
    $imageHolder = nil
    return
  end
end