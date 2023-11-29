class Admin::ContactsController < Admin::BaseController
  before_action :set_contact, only: %i[ show edit update destroy ]

  # GET /contacts or /contacts.json
  def index
    items = params[:items] || 5
    sort_column = params[:sort] || 'title'
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    @contacts = Contact.order_by(sort_column, sort_direction)
    @headers = %w[title email created_at]

    @pagy, @contacts = pagy(@contacts, items:)

    respond_to do |format|
      format.html # GET
      format.turbo_stream # POST
      format.json { render json: @contacts }
    end
  end

  # GET /contacts/1 or /contacts/1.json
  def show
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

    respond_to do |format|
      format.html { redirect_to contacts_url, notice: "Contact was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # POST /admin/contact/search
  def search
    text_fragment = params[:text]
    @filtered_contacts = Contact.all.filter_by_text(params[:text])
    @pagy, @filtered_contacts = pagy(@filtered_contacts, items: params[:items] || 15)
    respond_to do |format|
      format.turbo_stream do
        render 'admin/contacts/search_results'
      end
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
