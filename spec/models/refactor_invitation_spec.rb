require 'rails_helper'

RSpec.describe Invitation do
  def create_valid_intivation(team_name, user_email)
    team = Team.create(name: team_name)
    user = User.create(email: user_email)
    invitation = Invitation.new(team: team, user: user)

    invitation
  end

  describe 'send user invitation' do
    context 'with valid data' do
      it 'invites the user' do
        team = Team.create(name: 'A fine team')
        user = User.create(email: 'rookie@example.com')
        invitation = Invitation.new(team: team, user: user)

        invitation.save
        expect(user).to be_invited
      end
    end

    context 'with invalid data' do
      it 'does not save the invitation' do
        user = User.create(email: 'rookie@example.com')
        invitation = Invitation.new(team: nil, user: user)

        invitation.save
        expect(invitation).not_to be_valid
        expect(invitation).to be_new_record
      end

      it 'does not mark the user as invited' do
        user = User.create(email: 'rookie@example.com')
        invitation = Invitation.new(team: nil, user: user)

        invitation.save
        expect(user).not_to be_invited
      end
    end
  end

  describe 'event_log_statement' do
    context 'when record is saved' do
      it 'include name of the team' do
        invitation = create_valid_intivation('A fine team', 'rookie@example.com')

        invitation.save
        log_statement = invitation.event_log_statement

        expect(log_statement).to include('A fine team')
      end

      it 'include the email of the invitee' do
        invitation = create_valid_intivation('A fine team', 'rookie@example.com')

        invitation.save
        log_statement = invitation.event_log_statement

        expect(log_statement).to include('rookie@example.com')
      end
    end

    context 'when the record is not saved but valid' do
      it 'include name of the team' do
        invitation = create_valid_intivation('A fine team', 'rookie@example.com')

        log_statement = invitation.event_log_statement

        expect(log_statement).to include('A fine team')
      end

      it 'include the email of the invitee' do
        invitation = create_valid_intivation('A fine team', 'rookie@example.com')

        log_statement = invitation.event_log_statement

        expect(log_statement).to include('rookie@example.com')
      end

      it "includes the word 'PENDING'" do
        invitation = create_valid_intivation('A fine team', 'rookie@example.com')

        log_statement = invitation.event_log_statement

        expect(log_statement).to include('PENDING')
      end
    end

    context 'when the record is not saved and not valid' do
      it 'includes INVALID' do
        invitation = create_valid_intivation('A fine team', 'rookie@example.com')
        invitation.user = nil

        log_statement = invitation.event_log_statement
        expect(log_statement).to include('INVALID')
      end
    end
  end
end
