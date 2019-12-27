class ProviderError < StandardError
  class Deadlock < ProviderError
  end

  class Timeout < ProviderError
  end

  class Configuration < ProviderError
  end

  class Inventory < ProviderError
  end

  class Ignore < ProviderError
  end

  # 400
  class BadRequest < ProviderError
  end

  # 401
  class Unauthorized < ProviderError
  end

  # 403
  class Forbidden < ProviderError
  end

  # 404
  class RecordNotFound < ProviderError
  end

  # 405
  class MethodNotAllowed < ProviderError
  end

  # 406
  class NotAcceptable < ProviderError
  end

  # 408
  class Timeout < ProviderError
  end

  # 409
  class Conflict < ProviderError
  end

  # 415
  class UnsupportedMediaType < ProviderError
  end

  # 422
  class UnprocessableEntity < ProviderError
  end

  # 429
  class OverRateLimit < ProviderError
  end

  class SSLError < ProviderError
  end

  # 500+
  class InternalServerError < ProviderError
  end

  # 503
  class ServiceUnavailable < ProviderError
  end

  # ???
  class UnknownError < ProviderError
  end

  def self.codes
    {
      400 => ProviderError::BadRequest,
      401 => ProviderError::Unauthorized,
      403 => ProviderError::Forbidden,
      404 => ProviderError::RecordNotFound,
      405 => ProviderError::MethodNotAllowed,
      406 => ProviderError::NotAcceptable,
      408 => ProviderError::Timeout,
      409 => ProviderError::Conflict,
      415 => ProviderError::UnsupportedMediaType,
      422 => ProviderError::UnprocessableEntity,
      429 => ProviderError::OverRateLimit,
      495 => ProviderError::SSLError,
      500 => ProviderError::InternalServerError,
      503 => ProviderError::ServiceUnavailable
    }
  end
end
