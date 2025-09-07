class V1::DrawingsController < ApplicationController
  def index
    user = User.first
    @drawings = user.drawings.order(created_at: :desc)
  end

  def create
    user = User.first

    @drawing = user.drawings.build(label: drawing_params[:label])
    if drawing_params[:image].present?
      @drawing.image.attach(drawing_params[:image])
    end

    if @drawing.save
      render :show, status: :created, locals: { drawing: @drawing }
    else
      render :errors, status: :unprocessable_entity, locals: { record: @drawing }
    end
  end

  def show
    @drawing = Drawing.find(params[:id])
  end

  private
    def drawing_params
      params.permit(:image, :label)
    end
end
