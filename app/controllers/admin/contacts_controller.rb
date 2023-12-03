class Admin::ContactsController < Admin::BaseController
  before_action :set_contact, only: %i[ show edit update destroy ]

  # GET /contacts or /contacts.json
  def index
    add_breadcrumb t('breadcrumbs.contacts.index'), :admin_contacts_path
    items = params[:items]
    sort_column = params[:sort] || 'title'
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    @contacts = Contact.order_by(sort_column, sort_direction)
    @headers = %w[email title created_at]

    @pagy, @contacts = pagy(@contacts, items:)

    respond_to do |format|
      format.html # GET
      format.turbo_stream # POST
      format.json { render json: @contacts }
    end
  end

  # GET /contacts/1 or /contacts/1.json
  def show
    @contact.read! if @contact.unread?

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(@contact)
      end
    end
  end


  # GET /contacts/new
  def new
    @contact = Contact.new
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts or /contacts.json
  def create
    @contact = Contact.new(contact_params)

    respond_to do |format|
      if @contact.save
        format.html { redirect_to contact_url(@contact), notice: "Contact was successfully created." }
        format.json { render :show, status: :created, location: @contact }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts/1 or /contacts/1.json
  def update
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to contact_url(@contact), notice: "Contact was successfully updated." }
        format.json { render :show, status: :ok, location: @contact }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1 or /contacts/1.json
  def destroy
    @contact.destroy!
    @count = Contact.count

    respond_to do |format|
      flash.now[:success] = 'Contact was successfully destroyed.'
      format.html { redirect_to contacts_url }
      format.json { head :no_content }
      format.turbo_stream
    end
  end

  # POST /admin/contact/search
  def search
    if params[:text].blank?
      @pagy, @contacts = pagy(Contact.all, items: 10)
    else
      @contacts = Contact.all.filter_by_text(params[:text])
    end

    respond_to do |format|
      format.html # GET
      format.turbo_stream # POST
      format.json { render json: @contacts }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @contact = Contact.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def contact_params
      params.fetch(:contact, {})
    end
end
