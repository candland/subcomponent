# Subcomponent

When you want to create HTML simple components, using partials.

## Usage

Components are stored in `app/views/components` and are named `_component.html.erb`.
They can also be stored in a subdirectory of `app/views/components` and are named using the component name for the directory and the partial `component/_component.html.erb`.

Additional subcomponent partials can be included in the component directory allowing
to break up the component into smaller pieces.

### Example Simple Component

Create a button component in `app/views/components/_button.html.erb`:
```erb
<button>
  <%= this.text %>
</button>
```

Use `this` to access the component instance containing locals and subcomponents.

To use the component in a view:
```erb
<%= component :button, text: 'Click Me' %>
```

Using with the method_missing shorthand:
```erb
<%= button text: 'Click Me' %>
```

Locals can also be set within the component block:
```erb
<%= component :button do |c| %>
  <% c.text = 'Click Me' %>
<% end %>
```

### Example Component with Subcomponents

Create a card component in `app/views/components/card/_card.html.erb`:
```erb
<div>
  <%= this.render :title %>
  <%= this.text || this.yield %>
</div>
```

Create the title subcomponent in `app/views/components/card/_title.html.erb`:
```erb
<h1>
  <%= this.text %>
</h1>
```

You can use `this.render` to render a subcomponent. The subcomponent will have access
to the locals and subcomponents passed in the view.

You can use `this.yield` to render the block passed in the view.

To use the component in a view:
```erb
<%= component :card do |c| %>
  <%= c.title text: 'Card Title' %>
  <p>Card Text</p>
<% end %>
```

This will render:
```html
<div>
  <h1>Card Title</h1>
  <p>Card Text</p>
</div>
```

### Example Component with multiple Subcomponents

Create a card component in `app/views/components/card/_card.html.erb`:
```erb
<div>
  <% this.copy_components :links, :mobile_links %>
  <%= this.render :links %>
  <%= this.render :mobile_links %>
  <%= this.text || this.yield %>
</div>
```

Create the link subcomponent in `app/views/components/card/_link.html.erb`:
```erb
<a class="desktop" href="<%= this.url %>">
  <%= this.index %>: <%= this.text %>
</a>
```

Create the mobile_link subcomponent in `app/views/components/card/_mobile_link.html.erb`:
```erb
<a class="mobile" href="<%= this.url %>">
  <%= this.index %>: <%= this.text %>
</a>
```

You can use `this.render_all` to render multiple subcomponent. The subcomponent will have access
to the locals and subcomponents passed in the view. The components `index` method will be set.

To use the component in a view:
```erb
<%= component :card do |c| %>
  <%= c.link text: 'Card Link 1', url: '#" %>
  <%= c.link text: 'Card Link 2', url: '#" %>
  <p>Card Text</p>
<% end %>
```

This will render:
```html
<div>
  <a class="desktop" href="#">
    0: Card Link 1
  </a>
  <a class="desktop" href="#">
    1: Card Link 2
  </a>
  <a class="mobile" href="#">
    0: Card Link 1
  </a>
  <a class="mobile" href="#">
    1: Card Link 2
  </a>
  <p>Card Text</p>
</div>
```

### Example Using Locals without method_missing.

In some cases you may want to use a local variable that
clashes with existing methods on `Object`. In these cases you can access
the locals hash directly.
```erb
<h1>
  <%= this.local(:method) %>
</h1>
```

### Example Using Subcomponents without method_missing.

In some cases you may want to use a subcomponent that
clashes with existing methods on `Object`. In these cases you can access
the subcomponents hash directly.
```erb
<%= this.components(:method) %>
```

This returns and Array of subcomponents. You can render the first subcomponent with
a given key using, `this.render(:header)`.
```erb
<%= this.render(:header) %>
```

If you have multiple subcomponents with the same key, you can render them all using
`this.render_all(:header)`.
```erb
<%= this.render_all(:header) %>
```

If you want to render all subcomponents, but with HTML between them,
you can use `this.components(:actions)`.
```erb
<ul>
<% this.components(:actions).each do |sub| %>
  <li><%= sub.render %></li>
<% end %>
</ul>
```

## Installation

Add this line to your application's Gemfile:
```bash
$ bundle add subcomponent
```

Or install it yourself as:
```bash
$ gem install subcomponent
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/candland/subcomponent](https://github.com/candland/subcomponent).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
