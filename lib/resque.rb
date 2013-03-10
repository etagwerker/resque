require "resque/version"

require "resque/in_memory_queue"
require "resque/threaded_queue"
require "json"

class Resque
  def initialize(queue_class = InMemoryQueue)
    @queue_class = queue_class
  end

  def enqueue(klass, *args)
    queue[:default] << JSON.generate({:class => klass, :args => args})
  end

  def queue
    @queue ||= Hash.new(@queue_class.new)
  end

  def queue_implementation=(impl)
    @queue_class = impl
  end
  
  def process_job(queue_name=:default)
    job   = JSON.parse(Resque.queue[queue_name].pop)
    klass = job["class"]
    args  = job["args"]

    Kernel.const_get(klass).perform(*args)
  end
end

require "resque/compatibility"
