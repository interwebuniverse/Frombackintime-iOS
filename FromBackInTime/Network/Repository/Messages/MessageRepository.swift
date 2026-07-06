//
//  MessageRepository.swift
//  FromBackInTime
//
//  Media never flows through our backend: create the message, ask for a
//  presigned PUT, upload the blob straight to R2, then finalize (which verifies
//  the object landed and schedules standard messages).
//

import Foundation

protocol MessageRepositoryType {
    func list(kind: String?) async throws -> [MessageResponses.Message]
    func detail(id: String) async throws -> MessageResponses.Message
    func create(
        recipientId: String,
        kind: String,
        medium: String,
        occasion: String?,
        bodyText: String?,
        durationSeconds: Int?,
        deliverAt: String?
    ) async throws -> MessageResponses.Message
    func requestUploadURL(id: String, contentType: String) async throws -> MessageResponses.UploadURL
    func uploadMedia(to url: String, data: Data, contentType: String) async throws
    func finalize(id: String) async throws -> MessageResponses.Message
    func delete(id: String) async throws
}

final class MessageRepository: MessageRepositoryType {
    private let client: NetworkClientType

    init(client: NetworkClientType) {
        self.client = client
    }

    func list(kind: String?) async throws -> [MessageResponses.Message] {
        let res: BaseResponse<[MessageResponses.Message]> = try await client.request(MessageRequests.List(kind: kind))
        return res.data
    }

    func detail(id: String) async throws -> MessageResponses.Message {
        let res: BaseResponse<MessageResponses.Message> = try await client.request(MessageRequests.Detail(id: id))
        return res.data
    }

    func create(
        recipientId: String,
        kind: String,
        medium: String,
        occasion: String?,
        bodyText: String?,
        durationSeconds: Int?,
        deliverAt: String?
    ) async throws -> MessageResponses.Message {
        let body = MessageRequests.Create.Body(
            recipientId: recipientId,
            kind: kind,
            medium: medium,
            occasion: occasion,
            bodyText: bodyText,
            durationSeconds: durationSeconds,
            deliverAt: deliverAt
        )
        let res: BaseResponse<MessageResponses.Message> = try await client.request(MessageRequests.Create(body: body))
        return res.data
    }

    func requestUploadURL(id: String, contentType: String) async throws -> MessageResponses.UploadURL {
        let res: BaseResponse<MessageResponses.UploadURL> = try await client.request(
            MessageRequests.RequestUploadURL(id: id, contentType: contentType)
        )
        return res.data
    }

    func uploadMedia(to url: String, data: Data, contentType: String) async throws {
        try await client.upload(data, with: MessageRequests.UploadToR2(url: url, contentType: contentType))
    }

    func finalize(id: String) async throws -> MessageResponses.Message {
        let res: BaseResponse<MessageResponses.Message> = try await client.request(MessageRequests.Finalize(id: id))
        return res.data
    }

    func delete(id: String) async throws {
        let _: EmptyResponse = try await client.request(MessageRequests.Delete(id: id))
    }
}
