class AgentSearchesController < ApplicationController

  def show
    @search = AgentSearch.find(params[:id])

    if (params[:sort_by])
      @search.sort params[:sort_by]
    end

    # Caution: below line will flatten multi dimensional arrays
    agents_id_arr = @search.agent_ids.tr('[]', '').split(',').map(&:to_i)

    @agents = Agent.where(id: agents_id_arr).sort_by do |agent|
      agents_id_arr.index(agent.id)
    end
  end

  def create
    search = AgentSearch.new(params.permit(:txn_side, :prop_type, :price_range))
    
    if search.txn_side.blank? || search.prop_type.blank? || search.price_range.blank?
      redirect_to(root_path)
      return
    end
    
    search.find_agent_matches!

    if search.save
      redirect_to agent_search_path(search)
    end

  end
end
