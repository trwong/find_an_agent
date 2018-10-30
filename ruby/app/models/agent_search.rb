class AgentSearch < ApplicationRecord

  ###################################
  #
  #  Who: Full Stack Applicants, Backend Applicants, Data Applicants
  #
  #  Goal:
  #    To find a list of agents that best match the search parameters entered by the user. This
  #    is open to your interpretation. Your job is to think about what might matter to buyers/sellers
  #    and to implement a search function that effeciently finds a list.  See the Potential Considerations
  #    section below for starter ideas.
  #
  #  Reasoning: (please provide some commentary on your search algorithm)
  #
  #  Potential Considerations:
  #    - Buyers probably want people who have experience helping buyers, and same for sellers
  #    - Sellers probably want people who have experience selling their property type. Buyers might be more flexible
  #    - Buyers/Sellers at high price points are really picky about who they work with
  #    - Agents who work at higher price points really don't like working at low price points
  #
  ###################################

  PRICE_RANGE_HASH = {
    "0to150k" => "0_to_150k",
    "150kto300k" => "150k_to_300k",
    "300kto500k" => "300k_to_500k",
    "500kto750k" => "500k_to_750k",
    "750kto150k" => "750k_to_1m",
    "1mplus" => "1m_plus"
  }

  def find_agent_matches!
    agent_stats = AgentStat.all
    price_range = PRICE_RANGE_HASH[self.price_range]
    prop_type = self.prop_type

    agent_stats = agent_stats.select do |stat|
      # Filter by experience in price range
      price_bool = stat[price_range] > 0

      # Filter by experience buying/selling
      if (self.txn_side == "buying")
        txn_bool = stat["buyers"] > 0
      elsif (self.txn_side == "selling")
        txn_bool = stat["sellers"] > 0
      end

      # Filter by experience with property type
      prop_bool = stat[prop_type] > 0

      price_bool && txn_bool && prop_bool
    end

    # Sort by overall experience
    agent_stats = agent_stats.sort { |a, b| b.total - a.total }

    self.agent_ids = agent_stats.pluck(:agent_id);
  end

  def sort sort_by
    # Caution: below line will flatten multi dimensional arrays
    agents_id_arr = self.agent_ids.tr('[]', '').split(',').map(&:to_i)

    self.agent_ids = Agent.where(id: agents_id_arr)
                          .includes(:agent_stat)
                          .order("agent_stats.'#{sort_by}' DESC")
                          .pluck(:agent_id)
  end
end