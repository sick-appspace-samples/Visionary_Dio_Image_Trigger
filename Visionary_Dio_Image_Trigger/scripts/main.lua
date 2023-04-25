--[[----------------------------------------------------------------------------

  Application Name: Visionary_Dio_Image_Trigger
    
  Summary:
  Takes a snapshot when receiving a trigger signal.
  
  Description:
  Configures the first Digital IO to input and waits for a high signal. If
  a high signal is received a snapshot is triggered and shown in a Viewer.
  
  How to run:
  Start by running the app (F5) or debugging (F7+F10).
  Set a breakpoint on the first row inside the main function to debug step-by-step.
  See the results in the image viewer on the DevicePage.

    
------------------------------------------------------------------------------]]
--Start of Global Scope---------------------------------------------------------
-- Variables, constants, serves etc. should be declared here.
local v2D = View.create()
local cameraModel = nil
local provider = Image.Provider.Camera.create()
local dio1 = nil
--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------
---Callback funtion which is called when a new image is available
---@param image Image[] table which contains all received images
local function handleOnNewImage(images)
  v2D:clear()
  v2D:addDepthmap(images, cameraModel, nil, {"Intensity", "Statemap"})
  v2D:present()
end

---Callback which is called when the IO changes it states
---@param newState bool state of IO
local function handleOnChange(newState)
  -- triger snapshot if io changes to state active
  if newState == true then
    provider:snapshot()
  end
end

local function main()
  -- Configure frontend
  provider:stop()
  local captureConfig = provider:getConfig()
  captureConfig:setFramePeriod(33333)
  if provider:setConfig(captureConfig) == false then
    Log.severe("failed to configure capture device")
  end

  -- get camera model
  cameraModel = Image.Provider.Camera.getInitialCameraModel(provider)

  -- setup image call back
  local eventQueueHandle = Script.Queue.create()
  eventQueueHandle:setMaxQueueSize(1)
  eventQueueHandle:setPriority("HIGH")
  eventQueueHandle:setFunction(handleOnNewImage)
  provider:register("OnNewImage", handleOnNewImage)

  -- setup io
  dio1 = Connector.DigitalIn.create('DI1')
  dio1:register("OnChange", handleOnChange)
end
Script.register("Engine.OnStarted", main)
--End of Function and Event Scope-----------------------------------------------
