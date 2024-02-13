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

  def navbar_user_card_options
    {
      container: { style: 'flex justify-end items-center gap-4 px-2 relative' },
      button: { style: 'w-1/4 py-2 px-2 hover:cursor-pointer flex justify-end items-center gap-4' },
      avatar: {
        style: 'w-8 h-8 p-4 flex justify-center items-center bg-slate-200 border-4 border-indigo-600 rounded-full shadow shadow-indigo-100 text-slate-950 hover:text-red-500 hover:duration-500 duration-500 text-center font-bold uppercase'
      },
      dropdown: {
        style: 'w-full flex flex-col gap-6 hidden border-2 border-gray-950 text-slate-200 shadow-lg shadow-slate-500 shadow-t-none rounded-lg rounded-t-none p-4 bg-gray-950 opacity-0 transition-opacity duration-300 ease-in-out',
        position: 'absolute top-16 -right-4 z-40'
      }
    }
  end

  def navbar_items
    [
      { path: root_path, title: 'home' },
      { path: albums_path, title: 'galleries' },
      { path: contacts_path, title: 'contact' },
    ]
  end

  def user_card_unsigned_links
    [
      {
        li: { class: 'nav-link w-full flex justify-start items-center py-2 px-6 transition-all ease-in-out duration-1000' },
        link: { path: new_user_session_path, data: { turbo_frame: 'modal' }, class: 'w-full flex justify-start items-center gap-4' },
        title: { text: 'Iniciar sesión', class: 'text-white font-semibold' },
        icon: { svg: 'icons/user/user-up.svg', class: 'w-6 h-6 text-white' }
      },
      {
        li: { class: 'nav-link w-full flex justify-start items-center py-2 px-6 transition-all ease-in-out duration-1000' },
        link: { path: new_user_registration_path, data: { turbo_frame: 'modal' }, class: 'w-full flex justify-start items-center gap-4' },
        title: { text: 'Registrarse', class: 'text-white font-semibold' },
        icon: { svg: 'icons/user/user-plus.svg', class: 'w-6 h-6 text-white' }
      }
    ]
  end
end
