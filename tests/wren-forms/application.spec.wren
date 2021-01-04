import "augur" for Augur, Assert
import "wren-forms/application" for FormsApplication
import "wren-forms/controls" for Control
import "wren-forms/events" for UiEvent
import "wren-forms-mock-platform" for MockHost

Augur.describe(FormsApplication){
  
  Augur.it("runs"){
    var app = FormsApplication.new()
    MockHost.host(app)
    var rootControl = Control.new({})
    
    app.run(rootControl)

    Assert.isTrue(app.isRunning)
  }

  Augur.it("quits"){
    var app = FormsApplication.new()
    MockHost.host(app)
    var rootControl = Control.new({})
    app.resolve("EventSource").enqueue(UiEvent.new("quit", {}))
    
    app.run(rootControl)
    app.update()

    Assert.isTrue(app.shouldQuit)
  }
}

