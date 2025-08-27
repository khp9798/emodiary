package com.emodiary.backend.apiserver.dto.files;

import jakarta.validation.constraints.NotBlank;

public record PresignRequest(
	@NotBlank String fileName,
	@NotBlank String mimeType
){ }
