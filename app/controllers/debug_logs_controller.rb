class DebugLogsController < ApplicationController
  def index
    if Current.user&.admin? || Rails.env.development?
      item = Current.family.enable_banking_items.order(created_at: :desc).first
      
      return render plain: "No EnableBanking item found" unless item
      
      output = []
      output << "Debugging Item: #{item.id} (#{item.aspsp_name})"
      
      begin
        provider = item.enable_banking_provider
        output << "=> Provider loaded"
      rescue => e
        output << "ERROR Loading provider: #{e.message}"
      end
      
      # 1. Test get_accounts
      begin
        accounts = provider.get_accounts
        output << "=> GET /accounts returned #{accounts[:accounts]&.count || 0} accounts"
      rescue => e
        output << "ERROR in GET /accounts: #{e.message}"
      end
      
      # 2. Test fetching balances for each account
      item.enable_banking_accounts.each do |acc|
        output << "\\n--- Testing Account: #{acc.name} (API ID: #{acc.api_account_id}) ---"
        begin
          balances = provider.get_account_balances(account_id: acc.api_account_id)
          output << "=> BALANCES: #{balances.inspect}"
        rescue => e
          output << "ERROR getting balances: #{e.class} - #{e.message}"
        end
        
        begin
          transactions = provider.get_account_transactions(account_id: acc.api_account_id)
          output << "=> TRANSACTIONS: #{transactions[:transactions]&.count || 0} fetched"
        rescue => e
          output << "ERROR getting transactions: #{e.class} - #{e.message}"
        end
      end
      
      render plain: output.join("\\n")
    else
      render plain: "Unauthorized", status: :unauthorized
    end
  end
end
