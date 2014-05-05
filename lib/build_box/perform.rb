class BuildBox::Perform

  attr_accessor :output, :error, :code, :unbound_methods, :unbound_constants

  def initialize(code)
    self.unbound_methods   = []
    self.unbound_constants = []
    self.code = code
    evaluate
  end

  private

  def evaluate
    t = Thread.new do
      $SAFE = 3
      begin
        BuildBox.config.bad_methods.each {|meth| remove_method(meth.first, meth.last)}
        BuildBox.config.bad_constants.each {|const| remove_constant(const)}
        @output = eval(@code, TOPLEVEL_BINDING, "build_box")
        @error  = nil
      rescue Exception => e
        @error = "#{e.class}: #{e.to_s}"
      ensure
        restore_constants
        restore_methods
      end
    end

    timeout = t.join(BuildBox.config.timeout)
    if timeout.nil?
      @output = "BuildBoxError: execution expired"
      @error = true
    end
  end

  def remove_method(klass, method)
    const = Object.const_get(klass.to_s)
    if const.methods.include?(method) || const.instance_methods.include?(method)
      self.unbound_methods << [const, const.method(method).unbind]
      metaclass = class << const; self; end

      message = if const == Object
      "undefined local variable or method `#{method}' for main:Object"
    else
      "undefined local variable or method `#{method}' for #{klass}:#{const.class}"
    end

    metaclass.send(:define_method, method) do |*args|
      raise NameError, message
    end

    const.send(:define_method, method) do |*args|
      raise NameError, message
    end
  end
end

def restore_methods
  self.unbound_methods.each do |unbound|
    klass = unbound.first
    method = unbound.last

    metaclass = class << klass; self; end

    metaclass.send(:define_method, method.name) do |*args|
      method.bind(klass).call(*args)
    end

    klass.send(:define_method, method.name) do |*args|
      method.bind(klass).call(*args)
    end
  end
end

def remove_constant(constant)
  self.unbound_constants << Object.send(:remove_const, constant) if Object.const_defined?(constant)
end

def restore_constants
  self.unbound_constants.each {|const| Object.const_set(const.to_s.to_sym, const) unless Object.const_defined?(const.to_s.to_sym)}
end

end # BuildBox::Perform