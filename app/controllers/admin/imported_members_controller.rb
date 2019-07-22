class Admin::ImportedMembersController < Admin::ApplicationController
  expose(:members) { ImportedMember.uncontacted }

  def create
    CSV.read(create_params[:file].tempfile, headers: true, header_converters: :symbol).each do |row|
      add_import row
    end

    redirect_to admin_imported_members_path
  end

  private

  def create_params
    @create_params ||= params.slice(:source, :file)
  end

  def add_import(row)
    member = ImportedMember.find_or_initialize_by(email: row[:email])
    member.data_will_change!

    member.full_name ||= row[:name]
    member.data['sources'] ||= []
    member.data['sources'] << create_params[:source]
    member.save!
  end
end
