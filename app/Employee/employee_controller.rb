require 'rho/rhocontroller'
require 'helpers/browser_helper'

class EmployeeController < Rho::RhoController
  include BrowserHelper

  # GET /Employee
  def index
    @employees = Employee.find(:all)
    render :back => '/app'
  end

  # GET /Employee/{1}
  def show
    @employee = Employee.find(@params['id'])
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
  def create
    @employee = Employee.create(@params['employee'])
    $holdModelID = @employee.object
    redirect :action => :preparePic
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

  def preview_image
    #@employee = Employee.find(@params['id'])
    render :action => :postviewPic
  end
  
  
### Camera Related Methods ###
  
  def load_camera
    #objectID = $holdModelID
    puts "!!! Starting Camera !!!"
    #puts objectID
    #Rho::Camera.takePicture({}, :camera_callback)          API when Camera implementation is fixed
    Camera::take_picture(url_for(:action => :camera_callback))#, :id => $holdModelID))
  end

  def camera_callback
    #puts "HHHHHHHHHHHHHHHHHHHH+++++ #{@params['id']}"
    puts "HHHHHHHHHHHHHHHHHHHH+++++ #{$holdModelID}"
    #@employee = Employee.find(@params['id'])
    @employee = Employee.find($holdModelID)
    puts @params['status']
    puts @params['image_uri']
    puts @employee
    
    #Save the image to the New Employee/Guest
    if @params['status'] == 'ok'
      puts "Camera Picture Successful!"
      #@employee.update_attributes({:image => @params['image_uri']})
      $imageHolder = @params['image_uri']
      puts @employee
      puts Rho::Application.expandDatabaseBlobFilePath($imageHolder)
      Rho::WebView.navigate(url_for(:action => :preview_image)) #, :id => @employee.object))
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

  def load_picture
    
  end
end