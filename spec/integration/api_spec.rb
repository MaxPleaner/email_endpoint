# See spec/test_helpers.rb for the definitions of the utility methods used here
using TestHelpers

RSpec.describe "API" do

  context "POST /email" do

    let(:response_to_query_with_valid_params) do
      send_email_with_local_server(valid_params)
    end

    let(:response_to_query_with_invalid_params) do
      send_email_with_local_server(invalid_params)
    end

    describe "The endpoint returning JSON" do

      context "with valid params" do
        it "returns a JSON-encoded object" do
          response_to_query_with_valid_params.tap do |response|
            expect(response[:response]).to be_a Hash
            expect([200, 202]).to include response[:status_code]
          end
        end
      end

      context "with invalid params" do
        it "still returns a JSON-encoded object" do
          response_to_query_with_invalid_params.tap do |response|
            expect(response[:response]).to be_a Hash
            expect(response[:status_code]).to eq 422
          end
        end
      end

    end

    describe "Sanitizing HTML" do

      it "changes the HTML somehow" do
        html = "<p>foo</p>"
        expect(html).not_to eq(
          EmailSender.sanitize_html(html)
        )
      end

    end

    describe "The endpoint sending email" do

      context "with valid params" do
        it "sends an email." do
          with_smtp_server do |server|
            sleep 2.5 # give inbox time to settle
            server.fetch_unread # clear existing inbox
            expect(server.fetch_unread.length).to eq(0) # make sure it's empty
            result = response_to_query_with_valid_params
            expect([200, 202]).to include result[:status_code]
            sleep 2.5 # wait for email to arrive
            messages = server.fetch_unread
            expect(messages.length).to eq 1
            msg = messages.shift
            expect(msg.from_addrs[0]).to eq(valid_params["from"])
            # expect(msg.from).to eq(valid_params["from_name"])
            # expect(msg.to).to eq(valid_params["to_name"])
            expect(msg.subject).to eq(valid_params["subject"])
            expect(msg.body.to_s).to include(
              EmailSender.sanitize_html(valid_params["body"])
            )
          end
        end
      end

      context "with invalid params" do
        it "does not send an email" do
          with_smtp_server do |server|
            sleep 2.5 # give inbox time to settle
            server.fetch_unread # clear existing inbox
            expect(server.fetch_unread.length).to eq(0) # make sure it's empty
            response_to_query_with_invalid_params
            sleep 2.5 # wait for email to arrive
            expect(server.fetch_unread.length).to eq(0) # still empty
          end
        end
      end      

    end

    describe "status codes" do

      context "with valid params" do
        it "returns 200 or 202" do
          expect([200, 202]).to include response_to_query_with_valid_params[:status_code]
        end
      end

      context "with invalid params" do
        it "returns 422" do
          expect(response_to_query_with_invalid_params[:status_code]).to eq 422
        end
      end

    end

  end

end