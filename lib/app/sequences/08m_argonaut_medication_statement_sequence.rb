module Inferno
  module Sequence
    class ArgonautMedicationStatementSequence < SequenceBase

      title 'Medication Statement'

      description 'Verify that MedicationStatement resources on the FHIR server follow the Argonaut Data Query Implementation Guide'

      test_id_prefix 'ARMS'

      requires :token, :patient_id

      test 'Server rejects MedicationStatement search without authorization' do

        metadata {
          id '01'
          link 'http://www.fhir.org/guides/argonaut/r2/Conformance-server.html'
          desc %(
            A MedicationStatement search does not work without proper authorization.
          )
        }

        skip_if_not_supported(:MedicationStatement, [:search, :read])

        @client.set_no_auth
        skip 'Could not verify this functionality when bearer token is not set' if @instance.token.blank?

        reply = get_resource_by_params(FHIR::DSTU2::MedicationStatement, {patient: @instance.patient_id})
        @client.set_bearer_token(@instance.token)
        assert_response_unauthorized reply

      end

      test 'Server returns expected results from MedicationStatement search by patient' do

        metadata {
          id '02'
          link 'http://www.fhir.org/guides/argonaut/r2/Conformance-server.html'
          desc %(
            A server is capable of returning a patient's medications.
          )
        }

        skip_if_not_supported(:MedicationStatement, [:search, :read])

        reply = get_resource_by_params(FHIR::DSTU2::MedicationStatement, {patient: @instance.patient_id})
        assert_bundle_response(reply)

        @no_resources_found = false
        resource_count = reply.try(:resource).try(:entry).try(:length) || 0
        if resource_count === 0
          @no_resources_found = true
        end

        skip 'No resources appear to be available for this patient. Please use patients with more information.' if @no_resources_found

        @medicationstatement = reply.try(:resource).try(:entry).try(:first).try(:resource)
        validate_search_reply(FHIR::DSTU2::MedicationStatement, reply)
        save_resource_ids_in_bundle(FHIR::DSTU2::MedicationStatement, reply)

      end

      test 'MedicationStatement read resource supported' do

        metadata {
          id '03'
          link 'http://www.fhir.org/guides/argonaut/r2/Conformance-server.html'
          desc %(
            All servers SHALL make available the read interactions for the Argonaut Profiles the server chooses to support.
          )
        }

        skip_if_not_supported(:MedicationStatement, [:search, :read])
        skip 'No resources appear to be available for this patient. Please use patients with more information.' if @no_resources_found

        validate_read_reply(@medicationstatement, FHIR::DSTU2::MedicationStatement)

      end

      test 'MedicationStatement history resource supported' do

        metadata {
          id '04'
          link 'http://www.fhir.org/guides/argonaut/r2/Conformance-server.html'
          optional
          desc %(
            All servers SHOULD make available the vread and history-instance interactions for the Argonaut Profiles the server chooses to support.
          )
        }

        skip_if_not_supported(:MedicationStatement, [:history])
        skip 'No resources appear to be available for this patient. Please use patients with more information.' if @no_resources_found

        validate_history_reply(@medicationstatement, FHIR::DSTU2::MedicationStatement)

      end

      test 'MedicationStatement vread resource supported' do

        metadata {
          id '05'
          link 'http://www.fhir.org/guides/argonaut/r2/Conformance-server.html'
          optional
          desc %(
            All servers SHOULD make available the vread and history-instance interactions for the Argonaut Profiles the server chooses to support.
          )
        }

        skip_if_not_supported(:MedicationStatement, [:vread])
        skip 'No resources appear to be available for this patient. Please use patients with more information.' if @no_resources_found

        validate_vread_reply(@medicationstatement, FHIR::DSTU2::MedicationStatement)

      end

      test 'MedicationStatement resources associated with Patient conform to Argonaut profiles' do

        metadata {
          id '06'
          link 'http://www.fhir.org/guides/argonaut/r2/StructureDefinition-argo-medicationstatement.html'
          desc %(
            MedicationStatement resources associated with Patient conform to Argonaut profiles.
          )
        }
        test_resources_against_profile('MedicationStatement')
      end

    end

  end
end
