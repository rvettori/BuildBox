class BuildBox::Response

  attr_accessor :output, :error, :code # TODO: return de evaluated code

  alias :result :output

  def initialize(code, binding_context, security_level, timeout)
    evaluate(code, binding_context, security_level, timeout)
  end

  def error?
    !@error.nil?
  end

  private

  def evaluate(code, binding_context, security_level, timeout)
    preserve_namespace
    result  = BuildBox::Perform.new(code, binding_context, security_level, timeout)
    @output = result.output
    @error  = result.error
    @code   = result.code
    restore_namespace
    self
  end

  def preserve_namespace
    @old_constants = Object.constants
  end
  
  def restore_namespace
    (Object.constants - @old_constants).each {|bad_constant| Object.send(:remove_const, bad_constant)}
  end


end