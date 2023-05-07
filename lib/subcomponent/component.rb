class Component
  attr_accessor :_renderer
  attr_accessor :_capture

  def initialize name, locals, lookup_context, parent, block
    @_name = name
    @_parent = parent
    @_locals = locals
    @_lookup_context = lookup_context
    @_block = block

    @_components = {}
    @_building = false
  end

  def method_missing symbol, *args, **kwargs, &block
    # This is used when building a component
    if _building && symbol != :to_ary
      if symbol.ends_with?("=") && args.length == 1
        _locals[symbol[0..-2].to_sym] = args.first
      else
        _components[symbol] ||= []

        child = Component.new(symbol, args.first || kwargs, _lookup_context, self, block)
        child._renderer = _renderer
        child._capture = _capture
        child._capture_self

        _components[symbol] << child
      end
      nil

    # This is used when rendering a component
    elsif symbol.ends_with?("?")
      _locals.key?(symbol[0..-2].to_sym) || _components.key?(symbol[0..-2].to_sym)
    else
      _locals[symbol] || _components[symbol]
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
    missing = local_keys.reject { |k| _locals.key?(k) || _components.key?(k) }
    if missing.count > 0
      raise "The #{_name} component requires #{missing.join(", ")} local(s) or component(s)."
    end
    nil
  end

  def components key
    _components[key] || []
  end

  def local key
    _locals[key]
  end

  def render symbol = nil
    if symbol.nil?
      if _parent.nil?
        raise "Cannot render a component without a symbol when it has a parent."
      else
        return _yield_renderer
      end
    end
    _components[symbol]&.first&._yield_renderer
  end

  def render_all symbol
    _components[symbol]&.map(&:_yield_renderer)&.join&.html_safe
  end

  def yield
    _captured
  end

  def _yield_renderer
    locals = _locals.merge(this: self)
    _renderer.call(_partial, locals, _captured)
  end

  def _capture_self
    self._building = true
    self._captured = _capture.call(self, _block)
  ensure
    self._building = false
  end

  protected

  attr_reader :_name
  attr_reader :_locals
  attr_reader :_components
  attr_reader :_block
  attr_reader :_parent
  attr_accessor :_captured
  attr_reader :_lookup_context
  attr_accessor :_building

  def _base_name
    on = self
    until on._parent.nil?
      on = on._parent
    end
    on._name
  end

  def _partial
    @partial ||= if _lookup_context.exists?("components/#{_base_name}/#{_name}", [], true)
      "components/#{_base_name}/#{_name}"
    else
      "components/#{_name}"
    end
  end
end
