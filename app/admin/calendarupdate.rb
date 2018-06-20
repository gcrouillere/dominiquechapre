ActiveAdmin.register Calendarupdate do
  permit_params :period_start, :period_end, :available, :price_cents, :capacity, :name
  actions  :index, :new, :create, :destroy, :show
  menu priority: 4
  config.filters = false

  form do |f|
    f.inputs "" do
      f.input :period_start, as: :datepicker
      f.input :period_end, as: :datepicker
      f.input :price_cents, :hint => "Prix en centimes d'euros. Ex: entrez 1200 pour un prix de 12 €"
      f.input :capacity
      f.input :name
    end
    f.actions
  end

  index do
    column "Premier jour" do |calendarupdate|
      calendarupdate.period_start.strftime("%d/%m/%Y")
    end
    column "Dernier jour" do |calendarupdate|
      calendarupdate.period_end.strftime("%d/%m/%Y")
    end
    column :available
    column :capacity
    column :name
    actions
  end

  index_as_calendar ({:ajax => false}) do |calendarupdate|
    #Caractéristiques des évènements à afficher

    calendarupdate.available ? dispo = "#{calendarupdate.name} - places dispo" : dispo = "#{calendarupdate.name} - complet"

    {
      title: "#{dispo}",
      start: calendarupdate.period_start,
      end: calendarupdate.period_end + 1.day,
      url: "#{admin_calendarupdate_path(calendarupdate)}",
      textColor: '#2A2827',
      color: calendarupdate.available ? '#8CE35E' : '#e37d5e'
    }
  end

  show do |calendarupdate|
    attributes_table do
      row :period_start
      row :period_end
      row :available
      row :price_cents
      row :capacity
    end
  end

  controller do

    def create
      if params[:calendarupdate][:period_start] != "" && params[:calendarupdate][:period_end] != ""
        p_start = define_period_bound(params[:calendarupdate][:period_start])
        p_end = define_period_bound(params[:calendarupdate][:period_end])
        if p_end < p_start
          flash[:alert] = "Erreur : date de fin doit être après date de début"
          redirect_to admin_calendarupdates_path and return
        end
      else
        flash[:alert] = "Impossible d'effectuer l'action : certains champs n'étaient pas remplis"
        redirect_to admin_calendarupdates_path and return
      end

      super do |format|
        Calendarupdate.last.update(available: true) if resource.valid?
        redirect_to admin_calendarupdates_path and return if resource.valid?
      end
    end

    def destroy
      calendarupdate = Calendarupdate.find(params[:id])
      # Specific for CK :
      if Lesson.where(calendarupdate: calendarupdate).present?
        flash[:alert] = "Impossible de supprimer la réservation : certains jours étaient occupés par des réservations"
        redirect_to admin_calendarupdates_path
      else
        calendarupdate.destroy
        redirect_to admin_calendarupdates_path
      end
      # end
    end

    #Helper methods

    def define_period_bound(params_calendarupdate_periodbound)
      bounds = []
      for i in 0..2
        bounds << params_calendarupdate_periodbound.split('-').each.map {|string| string.to_i}[i]
      end
      output = DateTime.new(bounds[0],bounds[1],bounds[2])
      return output
    end

  end
end
