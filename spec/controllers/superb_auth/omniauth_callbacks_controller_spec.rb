RSpec.describe SuperbAuth::OmniauthCallbacksController, type: :controller do
  shared_examples 'any provider' do
    let(:uid) { '12345' }
    let(:user) { FactoryGirl.create(:user) }

    before do
      OmniAuth.config.add_mock(provider, { uid: uid })
      request.env['devise.mapping'] = Devise.mappings[:user]
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[provider] 
    end

    context 'identity exists' do
      let!(:identity) { FactoryGirl.create(:identity, provider: provider.to_s, uid: uid, user: user) }

      shared_examples 'action with identity' do
        it 'does not create new identities' do
          expect{ post provider }.not_to change(Identity, :count)
        end

        it 'does not create new users' do
          expect{ post provider }.not_to change(User, :count)
        end
      end

      context 'user signed in' do
        before { sign_in user }

        it_behaves_like 'action with identity'

        it 'redirects to profile page' do
          expect(post provider).to redirect_to(main_app.edit_user_registration_path)
        end

        it 'does not change current user' do
          expect { post provider }.not_to change { subject.current_user.id }
        end
      end

      context 'user is not signed in' do
        it_behaves_like 'action with identity'

        it 'redirects to root page' do
          expect(post provider).to redirect_to(main_app.root_path)
        end

        it 'signs in the user of identity' do
          expect { post provider }.to change { subject.current_user.try(:id) }.from(nil).to(user.id)
        end
      end
    end

    context 'indentity does not exist' do
      context 'user signed in' do
        before { sign_in user }

        it 'redirects to profile page' do
          expect(post provider).to redirect_to(main_app.edit_user_registration_path)
        end

        it 'creates new identity' do
          expect { post provider }.to change(Identity, :count).by(1)
          identity = Identity.last
          expect(identity.provider).to eq provider.to_s
          expect(identity.uid).to eq uid
          expect(identity.user_id).to eq user.id
        end

        it 'does not create new users' do
          expect{ post provider }.not_to change(User, :count)
        end

        it 'does not change current user' do
          expect { post provider }.not_to change { subject.current_user.id }
        end
      end

      context 'user is not signed in' do
        it 'redirects to root page' do
          expect(post provider).to redirect_to(main_app.root_path)
        end

        it 'creates new identity' do
          expect { post provider }.to change(Identity, :count).by(1)
          identity = Identity.last
          user = User.last
          expect(identity.provider).to eq provider.to_s
          expect(identity.uid).to eq uid
          expect(identity.user_id).to eq user.id
        end

        it 'creates new user' do
          expect { post provider }.to change(User, :count).by(1)
          identity = Identity.last
          user = User.last
          expect(user.identities.map(&:id).include?(identity.id)).to eq true
        end
      end
    end
  end

  describe 'facebook' do
    let(:provider) { :facebook }
    it_behaves_like 'any provider'
  end

  describe 'vkontakte' do
    let(:provider) { :vkontakte }
    it_behaves_like 'any provider'
  end

  describe 'twitter' do
    let(:provider) { :twitter }
    it_behaves_like 'any provider'
  end
end