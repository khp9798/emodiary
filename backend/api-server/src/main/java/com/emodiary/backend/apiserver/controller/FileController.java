package com.emodiary.backend.apiserver.controller;

import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.emodiary.backend.apiserver.dto.files.PresignRequest;
import com.emodiary.backend.apiserver.dto.files.PresignResponse;
import com.emodiary.backend.apiserver.service.storage.StorageService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/files")
public class FileController {

	private final StorageService storageService;

	@PostMapping("/presign")
	public ResponseEntity<PresignResponse> presign(@Valid @RequestBody PresignRequest request) {

		if (!request.mimeType().startsWith("audio/")) {
			return ResponseEntity.badRequest().build();
		}
		PresignResponse res = storageService.createPresignedUploadUrl(request.fileName(), request.mimeType());
		return ResponseEntity.ok(res);
	}
}
