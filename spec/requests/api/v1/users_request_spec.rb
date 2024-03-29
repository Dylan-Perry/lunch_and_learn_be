require 'rails_helper'

RSpec.describe "Users Request API" do
    describe "User Create" do
        describe "happy path" do
            it "creates a user" do
                user_params = {
                    name: "Miss Frizzle",
                    email: "thefrizz@gmail.com",
                    password: "donkus",
                    password_confirmation: "donkus"
                }
                headers = { 
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                }

                post api_v1_users_path, headers: headers, params: JSON.generate(user_params)

                new_user = User.last
                result = JSON.parse(response.body, symbolize_names: true)

                expect(response).to be_successful
                expect(response.status).to eq(201)

                expect(new_user.name).to eq(user_params[:name])
                expect(new_user.email).to eq(user_params[:email])
                expect(new_user.password).to eq(user_params[:password_digest])

                # JSON formatting according to front end spec
                expect(result[:data]).to be_a(Hash)

                expect(result[:data][:id]).to eq("1")
                expect(result[:data][:type]).to eq("user")

                # Exact attribute keys
                expect(result[:data][:attributes].count).to eq 3

                expect(result[:data][:attributes]).to have_key(:name)
                expect(result[:data][:attributes][:name]).to be_a(String)
                expect(result[:data][:attributes][:name]).to eq("Miss Frizzle")

                expect(result[:data][:attributes]).to have_key(:email)
                expect(result[:data][:attributes][:email]).to be_a(String)
                expect(result[:data][:attributes][:email]).to eq("thefrizz@gmail.com")

                expect(result[:data][:attributes]).to have_key(:api_key)
                expect(result[:data][:attributes][:api_key]).to be_a(String)
                expect(result[:data][:attributes][:api_key]).to eq(User.last.api_key)
            end
        end

        describe "sad path" do
            it "errors out when an email already exists" do
                user1 = User.create!(name: "Miss Frizzle", email: "thefrizz@gmail.com", password: "donkus", password_confirmation: "donkus")

                user_params = {
                    name: "Miss Frizzle",
                    email: "THEFRIZZ@gmail.com",
                    password: "donkus",
                    password_confirmation: "donkus"
                }
                headers = { 
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                }

                post api_v1_users_path, headers: headers, params: JSON.generate(user_params)

                expect(response).to_not be_successful 
                expect(response).to have_http_status(401)

                result = JSON.parse(response.body, symbolize_names: true)

                expect(result).to include({"email": ["has already been taken"]})
            end

            it "errors out when password does not match password confirmation" do

                user_params = {
                    name: "Miss Frizzle",
                    email: "THEFRIZZ@gmail.com",
                    password: "donkus",
                    password_confirmation: "chrysanthemum"
                }
                headers = { 
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                }

                post api_v1_users_path, headers: headers, params: JSON.generate(user_params)

                expect(response).to_not be_successful 
                expect(response).to have_http_status(401)

                result = JSON.parse(response.body, symbolize_names: true)

                expect(result).to include({"password_confirmation": ["doesn't match Password"]})
            end
        end
    end
end