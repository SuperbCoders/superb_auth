RSpec.describe SuperbAuth::IdentitiesController, type: :controller do
  routes { SuperbAuth::Engine.routes }

  describe 'destroy' do
    context 'with signed in user' do
      before { sign_in user }

      shared_examples 'any destroy method' do
        it 'redirects to profile' do
          expect(delete :destroy, provider: :facebook).to redirect_to(main_app.edit_user_registration_path)
        end
      end

      shared_examples 'non destroable situation' do
        it 'does not destroy any identities' do
          expect{ delete :destroy, provider: :facebook }.not_to change(Identity, :count)
        end
      end

      shared_examples 'destroable situation' do
        it 'destroys the identity' do
          expect{ delete :destroy, provider: :facebook }.to change(Identity, :count).by(-1)
          expect{ identity.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'user has specified identity' do
        let(:identity) { FactoryGirl.create(:identity, provider: 'facebook') }
        let(:user) { identity.user }

        context 'user has another identity' do
          before { FactoryGirl.create(:identity, provider: 'vkontakte', user: user) }
          it_behaves_like 'any destroy method'
          it_behaves_like 'destroable situation'
        end

        context 'user has email, but has not password' do
          before { user.update_attributes!(encrypted_password: '') }
          before { sign_in user } # the only way to remove the existing password
          it_behaves_like 'any destroy method'
          it_behaves_like 'non destroable situation'
        end

        context 'user has email and password' do
          it_behaves_like 'any destroy method'
          it_behaves_like 'destroable situation'
        end

        context 'user has neither email, nor other identities' do
          before { user.update_attributes!(email: nil, password: '') }
          it_behaves_like 'any destroy method'
          it_behaves_like 'non destroable situation'
        end
      end

      context 'user has not specified identity' do
        let(:user) { FactoryGirl.create(:user) }
        it_behaves_like 'any destroy method'
        it_behaves_like 'non destroable situation'
      end
    end

    context 'without signed in user' do
      # @todo
    end
  end

end