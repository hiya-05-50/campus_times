class AttendanceMarker
  Result = Struct.new(:success, :message, :error_code, :attendance, :class_session, keyword_init: true) do
    def success?
      success == true
    end

    def failure?
      !success?
    end
  end

  def self.call(token:, student:, ip_address: nil)
    new(token: token, student: student, ip_address: ip_address).call
  end

  def initialize(token:, student:, ip_address: nil)
    @token = token.to_s.strip
    @student = student
    @ip_address = ip_address
  end

  def call
    return failure(:missing_token, "Attendance token is required.") if @token.blank?
    return failure(:unauthenticated, "You must be signed in to mark attendance.") unless @student

    class_session = ClassSession.find_by(token: @token)
    return failure(:invalid_token, "Invalid attendance session token.") unless class_session

    return failure(:session_closed, "This attendance session has been closed by faculty.") if class_session.closed?
    return failure(:expired, "This attendance session link has expired.") if class_session.expired?

    course = class_session.course
    return failure(:not_enrolled, "You are not enrolled in #{course&.name || 'this course'}.") unless course&.enrolled?(@student)

    if Attendance.exists?(class_session_id: class_session.id, student_id: @student.id)
      return failure(:duplicate, "You have already marked attendance for this session.")
    end

    attendance = nil
    begin
      Attendance.transaction do
        attendance = Attendance.create!(
          class_session: class_session,
          student: @student,
          status: "present",
          marked_at: Time.current,
          ip_address: @ip_address
        )
      end
    rescue ActiveRecord::RecordNotUnique
      return failure(:duplicate, "You have already marked attendance for this session.")
    rescue ActiveRecord::RecordInvalid => e
      return failure(:validation_error, e.record.errors.full_messages.to_sentence)
    end

    Result.new(
      success: true,
      message: "Attendance recorded successfully for #{course.name}.",
      attendance: attendance,
      class_session: class_session
    )
  end

  private

  def failure(code, message)
    Result.new(success: false, error_code: code, message: message)
  end
end
