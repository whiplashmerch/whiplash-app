class WhiplashApiError < StandardError
  class Deadlock < WhiplashApiError
  end

  class Timeout < WhiplashApiError
  end

  class Configuration < WhiplashApiError
  end

  class Inventory < WhiplashApiError
  end

  class Ignore < WhiplashApiError
  end

  # 400
  class BadRequest < WhiplashApiError
  end

  # 401
  class Unauthorized < WhiplashApiError
  end

  # 403
  class Forbidden < WhiplashApiError
  end

  # 404
  class RecordNotFound < WhiplashApiError
  end

  # 405
  class MethodNotAllowed < WhiplashApiError
  end

  # 406
  class NotAcceptable < WhiplashApiError
  end

  # 408
  class Timeout < WhiplashApiError
  end

  # 409
  class Conflict < WhiplashApiError
  end

  # 415
  class UnsupportedMediaType < WhiplashApiError
  end

  # 422
  class UnprocessableEntity < WhiplashApiError
  end

  # 429
  class OverRateLimit < WhiplashApiError
  end

  class SSLError < WhiplashApiError
  end

  # 500+
  class InternalServerError < WhiplashApiError
  end

  # 502
  class Timeout < WhiplashApiError
  end

  # 503
  class ServiceUnavailable < WhiplashApiError
  end

  # ???
  class UnknownError < WhiplashApiError
  end

  def self.codes
    {
      400 => WhiplashApiError::BadRequest,
      401 => WhiplashApiError::Unauthorized,
      403 => WhiplashApiError::Forbidden,
      404 => WhiplashApiError::RecordNotFound,
      405 => WhiplashApiError::MethodNotAllowed,
      406 => WhiplashApiError::NotAcceptable,
      408 => WhiplashApiError::Timeout,
      409 => WhiplashApiError::Conflict,
      415 => WhiplashApiError::UnsupportedMediaType,
      422 => WhiplashApiError::UnprocessableEntity,
      429 => WhiplashApiError::OverRateLimit,
      495 => WhiplashApiError::SSLError,
      500 => WhiplashApiError::InternalServerError,
      502 => WhiplashApiError::Timeout,
      503 => WhiplashApiError::ServiceUnavailable
    }
  end
end
