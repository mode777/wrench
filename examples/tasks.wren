import "tasks" for Task, Canceller

class Helpers {
  static createCounter(name, start, end, cancel){
    return Task.new(cancel) {|c|
      for(i in start...end){
        if(c.isCancelled){
          break
        } else {
          Fiber.yield(i)
          Task.delay(0.1, c)
        }
      }
      return "%(name) done"
    }
  }
}

var cancel = Canceller.new()
 
var main = Task.new(cancel) {|c|
  var result1 = Helpers.createCounter("Task 1", 0, 5, c).subscribe{|x| System.print(x) }.await()
  var result2 = Helpers.createCounter("Task 2", 5, 10, c).subscribe{|x| System.print(x) }.await()
  System.print("%(result1), %(result2)")

  c.cancel()

  var task3 = Helpers.createCounter("Task 3", 10, 15, c).subscribe{|x| System.print(x) }
  var task4 = Helpers.createCounter("Task 4", 15, 20, c).subscribe{|x| System.print(x) }
  System.print(Task.awaitAll([task3, task4]))
}.getResult()