class Api::V1::DrawingsController < ApplicationController
  def index
    user = User.find(1)
    drawings = user.drawings.order(created_at: :desc)
    render :index, locals: { drawings: drawings }
  end

  def create
    user = User.find(1)

    drawing = user.drawings.build(label: drawing_params[:label])
    if drawing_params[:image].present?
      drawing.image.attach(drawing_params[:image])
    end

    if drawing.save
      render :show, status: :created, locals: { drawing: drawing }
    else
      render :errors, status: :unprocessable_entity, locals: { record: drawing }
    end
  end

  def show
  end

  private
    def drawing_params
      params.permit(:image, :label)
    end
end
