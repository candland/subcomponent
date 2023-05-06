class Component
  attr_reader :name
  attr_reader :locals
  attr_reader :block
  attr_reader :parent
  attr_writer :renderer
  attr_writer :capture
  attr_reader :captured
  attr_reader :lookup_context

  def initialize name, locals, lookup_context, parent, block
    @name = name
    @parent = parent

    @components = {}
    @locals = locals
    @lookup_context = lookup_context
    @block = block
    @dynamic = false
  end

  def method_missing symbol, *args, **kwargs, &block
    # This is used when using a component
    if @dynamic && symbol != :to_ary
      if symbol.ends_with?("=") && args.length == 1
        @locals[symbol[0..-2].to_sym] = args.first
      else
        @components[symbol] ||= []

        child = Component.new(symbol, args.first || kwargs, @lookup_context, self, block)
        child.renderer = @renderer
        child.capture = @capture
        child.capture_self

        @components[symbol] << child
      end
      nil

    # This is used when rendering a component
    elsif symbol.ends_with?("?")
      @locals.key?(symbol[0..-2].to_sym) || @components.key?(symbol[0..-2].to_sym)
    else
      @locals[symbol] || @components[symbol]
    end
  end

  def respond_to_missing? symbol, *args
    if symbol != :to_ary
      true
    else
      super
    end
  end

  def require *local_keys
    missing = local_keys.reject { |k| @locals.key?(k) || @components.key?(k) }
    if missing.count > 0
      raise "The #{name} component requires #{missing.join(", ")} local(s) or component(s)."
    end
    nil
  end

  def components key
    @components[key] || []
  end

  def render symbol = nil
    if symbol.nil?
      if parent.nil?
        raise "Cannot render a component without a symbol when it has a parent."
      else
        return yield_renderer
      end
    end
    @components[symbol]&.first&.yield_renderer
  end

  def render_all symbol
    @components[symbol]&.map(&:yield_renderer)&.join&.html_safe
  end

  def yield_renderer
    @renderer.call(self)
  end

  def yield
    captured
  end

  def capture_self
    @dynamic = true
    @captured = @capture.call(self)
  ensure
    @dynamic = false
  end

  def base_name
    on = self
    until on.parent.nil?
      on = on.parent
    end
    on.name
  end
end
