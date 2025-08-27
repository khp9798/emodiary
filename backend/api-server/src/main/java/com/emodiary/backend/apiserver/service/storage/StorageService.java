package com.emodiary.backend.apiserver.service.storage;

import com.emodiary.backend.apiserver.dto.files.PresignResponse;

public interface StorageService {

	PresignResponse createPresignedUploadUrl(String fileName, String mimeType);
}
