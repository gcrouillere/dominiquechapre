ActiveAdmin.register Lesson do
  permit_params :confirmed
  actions  :index, :destroy, :update, :edit, :show
  config.sort_order = 'start_asc'
  menu priority: 5
  config.filters = false

  index do
    render 'current_week_lessons'
    column "Début" do |lesson|
       lesson.start.strftime("%d/%m/%Y")
    end
    column :student
    column "Client" do |lesson|
      lesson.user.email
    end
    column :confirmed
    column "Payée ?" do |lesson|
      order = Order.where(lesson: lesson).first
      order.present? ? order.state == "paid" : false
    end
    actions
  end

  index_as_calendar ({:ajax => false}) do |lesson|
    #Caractéristiques des évènements à afficher
    confirmation = ""
    lesson.confirmed ? confirmation = "oui" : confirmation = "non"
    order = Order.where(lesson: lesson).first
    order.present? ? (order.state == "paid" ? payment = "oui" : payment = "non") : payment = "non"
    order.present? ? (order.state == "paid" ? is_paid = true : is_paid = false) : is_paid = false

    #Paramètres pour index_as_calendar
    {
      title: "#{lesson.calendarupdate.name} - #{lesson.student} personnes - Confirmée: #{confirmation} - Payée: #{payment}",
      start: lesson.start,
      end: (lesson.start + lesson.duration.day),
      url: "#{admin_lesson_path(lesson)}",
      textColor: '#2A2827',
      color: (is_paid ? '#8CE35E' : (lesson.confirmed ? '#FFD938' : '#FF9E6A'))
    }
  end

  show do |lesson|
    attributes_table do
      row "Début" do
       "#{lesson.start.day} #{lesson.start.strftime("%B")} #{lesson.start.year}"
      end
      row :duration
      row :user
      row :confirmed
      row :student
      row "Paiement" do |lesson|
        Order.where(lesson: lesson).present? ? (Order.where(lesson: lesson).first.state == "pending" ? "Non payé" : "Payé") : "Non payé"
      end
    end
  end

  controller do

    def index
      super do |format|
        @current_week_lessons_a = Lesson.where("confirmed = ? AND start >= ?", true, Time.now - 20 * 3600 * 24).joins(:order).order(start: :asc).where("lesson_id IS NOT NULL")
        @pending_lessons = Lesson.where("confirmed = ? AND start >= ?", false, Time.now)
        Lesson.all.each do |lesson|
          if !lesson.confirmed? && lesson.start < Time.now
            lesson.destroy
          end
        end
      end
    end

    def update
      lesson = Lesson.find(params[:id].to_i)
      calendarupdate = lesson.calendarupdate

      if params[:lesson][:confirmed] == "1" # Si la réservation va être confirmée
        if calendarupdate.capacity >= lesson.student
          calendarupdate.update(capacity: calendarupdate.capacity - lesson.student)
          if calendarupdate.capacity == 0
            calendarupdate.update(available: false)
          end
          create_order_for_lesson(lesson)
          LessonMailer.mail_user_after_confirmation(lesson).deliver_now
        else
          flash[:alert] = "Capacité insuffisante, confirmation impossible. Il faut : soit supprimer cette demande, soit annuler une réservation déjà confirmée."
          redirect_to admin_lessons_path and return
        end
        lesson.update(confirmed: true)
        redirect_to admin_lessons_path and return
      end
      redirect_to admin_lessons_path
    end

    def destroy
      lesson = Lesson.find(params[:id].to_i)
      calendarupdate = lesson.calendarupdate
      calendarupdate.update(capacity: calendarupdate.capacity + lesson.student) if lesson.confirmed
      if calendarupdate.capacity > 0
        calendarupdate.update(available: true)
      end
      order = Order.where(lesson: lesson).first
      order_destroy_if_pending(order)
      LessonMailer.mail_user_after_lesson_destroy(lesson).deliver_now

      super do |format|
        redirect_to admin_lessons_path and return if resource.valid?
      end
    end

    #Helper methods

    def create_order_for_lesson(lesson)
      Order.create!(
        state: 'pending',
        amount_cents: lesson.calendarupdate.price_cents * ENV['LESSONDEPOSITRATIO'].to_i,
        user: lesson.user,
        lesson: lesson,
        take_away: false
      )
    end

    def order_destroy_if_pending(order)
      if order
        order.update(lesson: nil)
        if order.state == "pending"
          order.destroy
        end
      end
    end

  end
end
