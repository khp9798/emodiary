package com.emodiary.backend.apiserver.dto.files;

public record PresignResponse(
	String uploadUrl,
	String key,
	long expiresInSec
) { }
