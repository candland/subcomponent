module ComponentHelper
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

  alias_method :comp, :component

  def method_missing symbol, *args, **kwargs, &block
    super unless respond_to?(symbol)

    component symbol, *args, **kwargs, &block
  end

  def respond_to_missing? symbol, *args
    lookup_context.exists?("components/#{symbol}/#{symbol}", [], true) ||
      lookup_context.exists?("components/#{symbol}", [], true)
  end
end
