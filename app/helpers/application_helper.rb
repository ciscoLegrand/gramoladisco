module ApplicationHelper
  include Pagy::Frontend

  def active_link_to(text= nil, path = nil, **options, &block)
    link = block_given? ? text : path

    options[:class] = class_names(options[:class], 'nav-link-active') if current_page?(link)

    if block_given?
      link_to(text, options, &block)
    else
      link_to(text, path, options)
    end
  end

  def navbar_items
    [
      { path: root_path, title: 'Inicio' },
      { path: albums_path, title: 'Galleries' },
      { path: contacts_path, title: 'Contact' },
    ]
  end

  def aside_items
    [
      { path: root_path, title: 'Inicio', icon: 'icons/aside/home.svg' },
      { path: admin_albums_path, title: 'Albums', icon: 'icons/aside/photo.svg' },
      { path: '#', title: 'Categories', icon: 'icons/aside/category.svg' },
      { path: '#', title: 'Products', icon: 'icons/aside/dj.svg' },
      { path: admin_contacts_path, title: 'Contact', icon: 'icons/contact/inbox.svg' }
    ]
  end
end
