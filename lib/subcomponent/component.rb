class Component
  attr_accessor :_renderer
  attr_accessor :_capture

  # Use Component::ComponentHelper to create components.
  def initialize name, locals, lookup_context, parent, block
    @_name = name
    @_parent = parent
    @_locals = locals
    @_lookup_context = lookup_context
    @_block = block

    @_components = {}
    @_building = false
  end

  # Specify and use local values or sub-components using method calls.
  #
  # == Locals
  #
  # @example
  #
  #   = component :header do |c|
  #     c.title = "Hello"
  #
  # In the component:
  #
  # @example
  #
  #   = this.title
  #
  # @return "Hello"
  #
  # == Sub-components
  #
  # @example
  #
  #   = component :card do |c|
  #     - c.header do |c|
  #       - c.title = "Hello"
  #
  # In the component:
  #
  # @example
  #
  #   = this.render :header
  #
  #   = this.header.render
  #
  # @return The rendered component
  #
  # == Checking for locals or sub-components
  #
  # @example
  #
  #   = this.title?
  #   = this.header?
  #
  # @return true or false
  #
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

  # :nodoc:
  def respond_to_missing? symbol, *args
    if symbol != :to_ary
      true
    else
      super
    end
  end

  # This is used to require local keys or sub-components.
  #
  # @param [Array<Symbol>] loacl_keys
  #
  #   require :title, :body
  #
  def require *local_keys
    missing = local_keys.reject { |k| _locals.key?(k) || _components.key?(k) }
    if missing.count > 0
      raise "The #{_name} component requires #{missing.join(", ")} local(s) or component(s)."
    end
    nil
  end

  # This is used to access sub-components passed to the component.
  #
  # @param [Symbol] key The name of the sub-component
  #
  # @example
  #
  #   components :header
  #
  #   returns: [<Component>, <Component>, ...]
  #
  def components key
    _components[key] || []
  end

  # This is used to access locals passed to the component.
  def local key
    _locals[key]
  end

  # This is used to render a sub-component.
  #
  # From within a component:
  #
  #   this.render :header
  #
  # Or calling directly on a sub-component:
  #
  #   this.header.render
  #
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

  # Render all sub-components of a given name.
  #
  #   this.render_all :header
  #
  # Returns a string of all rednered sub-components.
  #
  def render_all symbol
    _components[symbol]&.map(&:_yield_renderer)&.join&.html_safe
  end

  # Yield the block passed to the component.
  #
  #   this.yield
  #
  def yield
    _captured
  end

  # :nodoc:
  def _yield_renderer
    locals = _locals.merge(this: self)
    _renderer.call(_partial, locals, _captured)
  end

  # :nodoc:
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

  # :nodoc:
  def _base_name
    on = self
    until on._parent.nil?
      on = on._parent
    end
    on._name
  end

  # :nodoc:
  def _partial
    @partial ||= if _lookup_context.exists?("components/#{_base_name}/#{_name}", [], true)
      "components/#{_base_name}/#{_name}"
    else
      "components/#{_name}"
    end
  end
end
