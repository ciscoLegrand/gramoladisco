module AdminHelper
  def aside_user_card_options
    {
      container: {
        style: 'flex justify-end items-center gap-4 px-2 relative'
      },
      button: {
        style: 'w-1/4 py-2 px-2 hover:cursor-pointer flex justify-end items-center gap-4'
      },
      avatar: {
        style: 'w-8 h-8 p-4 flex justify-center items-center bg-slate-200 border-4 border-indigo-600 rounded-full shadow shadow-indigo-100 text-slate-950 hover:text-red-500 hover:duration-500 duration-500 text-center font-bold uppercase'
      },
      dropdown: {
        style: 'w-full flex flex-col gap-6 hidden border-2 border-gray-950 text-slate-200 shadow-lg shadow-slate-500 shadow-t-none rounded-lg rounded-t-none p-4 bg-gray-950 opacity-0 transition-opacity duration-300 ease-in-out',
        position: 'absolute -bottom-[9.4rem] -right-7 z-40'
      }
    }
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
