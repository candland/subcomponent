module ComponentHelper
  def component name, **kwargs, &block
    component = Component.new(name, kwargs, lookup_context, nil, block)

    component.renderer = proc do |component|
      partial = if component.lookup_context.exists?("components/#{component.base_name}/#{component.name}", [], true)
        "components/#{component.base_name}/#{component.name}"
      else
        "components/#{component.name}"
      end

      render partial, component.locals.merge(this: component) do
        component.captured
      end
    end

    component.capture = proc do |component|
      if component.block
        capture do
          component.block.call(component)
        end
      end
    end

    component.capture_self
    component.yield_renderer
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
