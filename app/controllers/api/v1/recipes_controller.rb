class Api::V1::RecipesController < ApplicationController

    # GET /api/v1/recipes
    def index
        results = RecipeFacade.new(params[:country]).recipes_by_country
        render json: RecipeSerializer.new(results)
    end
end