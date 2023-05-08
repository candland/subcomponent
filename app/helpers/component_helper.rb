module ComponentHelper
  # Create a component in a view.
  #
  # @param [Symbol] name The name of the component.
  # @param [Hash] kwargs The locals to pass to the component.
  # @param [Proc] block The block to pass to the component. You can use
  # other components inside this block. You can set locals inside this
  # block.
  #
  # @example
  #
  #  = component :header do |c|
  #    - c.title = "Hello"
  #    p My Extra Content
  #
  def component name, **kwargs, &block
    component = Component.new(name, kwargs, lookup_context, nil, block)

    component._renderer = proc do |partial, locals, captured|
      render partial, locals do
        captured
      end
    end

    component._capture = proc do |component, block|
      if block
        capture do
          block.call(component)
        end
      end
    end

    component._capture_self
    component._yield_renderer
  end

  # Alias for component.
  alias_method :comp, :component

  # Create a component in a view with shorthand syntax.
  # This is the same as calling component with the same arguments.
  #
  # @example
  #
  #   = header do |c|
  #     - c.title = "Hello"
  #
  def method_missing symbol, *args, **kwargs, &block
    super unless respond_to?(symbol)

    component symbol, *args, **kwargs, &block
  end

  # :nodoc:
  def respond_to_missing? symbol, *args
    lookup_context.exists?("components/#{symbol}/#{symbol}", [], true) ||
      lookup_context.exists?("components/#{symbol}", [], true)
  end
end
