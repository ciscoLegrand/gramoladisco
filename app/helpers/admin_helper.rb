module AdminHelper
  def admin_navbar_user_card_options
    {
      container: {
        style: 'flex justify-end items-center gap-4 px-2 relative'
      },
      button: {
        style: 'w-1/4 py-2 px-2 hover:cursor-pointer flex justify-end items-center gap-4'
      },
      avatar: {
        style: 'w-12 h-12 p-4 flex justify-center items-center bg-slate-950 border-4 border-indigo-600 rounded-full shadow-lg shadow-slate-950 text-slate-300 hover:text-red-500 hover:duration-500 duration-500 text-center font-bold uppercase'
      },
      dropdown: {
        style: 'w-full h-72 flex flex-col gap-6 hidden border-2 border-gray-950 text-slate-200 shadow-lg shadow-slate-500 shadow-t-none rounded-lg p-4 bg-gray-950 opacity-0 transition-opacity duration-300 ease-in-out',
        position: 'absolute top-16 right-0 z-40'
      }
    }
  end

  def aside_user_card_options
    {
      container: {
        style: 'sticky bottom-4 left-6 w-full mr-2 flex flex-col items-center bg-indigo-700 rounded-xl gap-8 shadow-md shadow-slate-700'
      },
      button: {
        style: 'w-full py-8 px-4 hover:cursor-pointer flex justify-center items-center gap-4'
      },
      avatar:{
        style: 'w-12 h-12 p-5 flex justify-center items-center bg-corporation border-2 border-indigo-600 bg-slate-950 rounded-full shadow-lg text-white hover:text-red-500 hover:duration-500 duration-500 text-center font-semibold uppercase'
      },
      dropdown: {
        style: 'w-full flex flex-col gap-6 hidden border-2 border-slate-950 text-slate-200 shadow-lg shadow-slate-500 rounded-lg p-4 bg-slate-950 opacity-0 transition-opacity duration-300 ease-in-out',
        position: 'absolute -top-40 left-0'
      }
    }
  end

  def aside_items
    [
      { path: admin_root_path, title: 'Inicio', icon: 'icons/aside/home.svg' },
      { path: admin_albums_path(items: params[:items].presence || 10), title: 'Albums', icon: 'icons/aside/photo.svg' },
      { path: '#', title: 'Categories', icon: 'icons/aside/category.svg' },
      { path: '#', title: 'Products', icon: 'icons/aside/dj.svg' },
      { path: admin_contacts_path(items: params[:items].presence || 10), title: 'Contact', icon: 'icons/contact/inbox.svg' }
    ]
  end

  def user_card_signed_links
    [
      {
        li: { class: 'nav-link w-full flex justify-start items-center py-2 px-6 transition-all ease-in-out duration-1000' },
        link: { path: edit_user_registration_path, class: 'w-full flex justify-start items-center gap-4' },
        title: { text: 'Editar perfil', class: 'text-white font-semibold' },
        icon: { svg: 'icons/user/user-cog.svg', class: 'w-6 h-6 text-white' }
      },
      {
        li: { class: 'nav-link w-full flex justify-start items-center py-2 px-6 transition-all ease-in-out duration-1000' },
        link: { path: destroy_user_session_path, data: { turbo_method: :delete }, class: 'w-full flex justify-start items-center gap-4' },
        title: { text: 'Cerrar sesión', class: 'text-white font-semibold' },
        icon: { svg: 'icons/user/user-x.svg', class: 'w-6 h-6 text-white' }
      }
    ]
  end

  def user_card_admin_links
    [
      {
        li: { class: 'nav-link w-full flex justify-start items-center py-2 px-6 transition-all ease-in-out duration-1000' },
        link: { path: admin_root_path, class: 'w-full flex justify-start items-center gap-4' },
        title: { text: 'Panel de control', class: 'text-white font-semibold' },
        icon: { svg: 'icons/user/mood-cog.svg', class: 'w-6 h-6 text-white' }
      },
      {
        li: { class: 'nav-link w-full flex justify-start items-center py-2 px-6 transition-all ease-in-out duration-1000' },
        link: { path: new_admin_album_path, class: 'w-full flex justify-start items-center gap-4' },
        title: { text: 'Añadir album', class: 'text-white font-semibold' },
        icon: { svg: 'icons/shared/photo-plus.svg', class: 'w-6 h-6 text-white' }
      }
    ]
  end
end
