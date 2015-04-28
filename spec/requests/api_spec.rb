require 'rest_client'
require 'json_expressions/rspec'
require 'rails_helper'

describe 'Punchcard API' do

  it 'Test API' do
    API_URL = 'http://localhost:3000/api'
    # User API
    result = RestClient.post API_URL + '/login.json', content_type: :json, email: 'jason.pang@gmail.com', password: 'password'
    json = JSON.parse(result)
    expect(result.code).to eq(201)

    # {"user":{"id":2,"email":"jason.pang@gmail.com","auth_token":"SYecxbJf6gKkDp6ei56zR4xZ5xYwPGYx1Q","auth_token_expiry":"2015-04-28T11:33:44.313+08:00"}}
    assert user = json['user']
    expect(user['email']).to eq('jason.pang@gmail.com')

    user_id = user['id']
    expect(user_id).to be > 0
    auth_token = user['auth_token']

    # Company API
    result = RestClient.get API_URL + '/companies.json', { 'X-API-EMAIL' => 'jason.pang@gmail.com', 'X-API-TOKEN' => auth_token }
    json = JSON.parse(result)
    expect(result.code).to eq(200)

    # {"company"=>{"id"=>2, "name"=>"J-Solutions 2 Pte Ltd", "time"=>"2015-04-28T11:28:59.563+08:00", "projects"=>[{"id"=>1, "name"=>"Punggol Emerald", "location"=>"1.405573,103.897984"}]}}
    assert company = json['company']
    company_id = company['id']
    expect(company_id).to be > 0
    assert projects = company['projects']
    project_id = projects[0]['id']
    expect(project_id).to be > 0

    # Worker API
    result = RestClient.get API_URL + '/workers/work_permit/S7705835D', { 'X-API-EMAIL' => 'jason.pang@gmail.com', 'X-API-TOKEN' => auth_token }
    json = JSON.parse(result)
    #puts json
    expect(result.code).to eq(200)
    # {"worker"=>{"id"=>1, "name"=>"Jason Pang"}}
    assert worker = json['worker']
    worker_id = worker['id']
    expect(worker_id).to be > 0

    params = { checkin: '2015-04-28 14:18:43', checkout: '2015-04-28 14:18:43', checkin_location: '1,0,1.0', checkout_location: '1,0,1.0', company_id: company_id, project_id: project_id, worker_id: worker_id, user_id: user_id }
    headers = { 'X-API-EMAIL' => 'jason.pang@gmail.com', 'X-API-TOKEN' => auth_token}
    result = RestClient.post(API_URL + '/punchcards.json', params, headers) { |response, request, result, &block|
      case response.code
        when 200
          json = JSON.parse(response)
          puts json
          expect(response.code).to eq(200)
        when 302
          response
          #response.follow_redirection(request, result, &block)
          expect(response.code).to eq(302)
        else
          response.return!(request, result, &block)
      end
    }

    #json = JSON.parse(result)
    #puts json
    #assert punchcard = json['punchcard']
    #punchcard_id = punchcard['id']
    #expect(punchcard_id).to be > 0
  end
end
