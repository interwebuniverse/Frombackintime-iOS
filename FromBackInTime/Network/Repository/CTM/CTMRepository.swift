//
//  CTMRepository.swift
//  FromBackInTime
//

import Foundation

protocol CTMRepositoryType {
    func activate(messageId: String, checkinIntervalDays: Int?, releaseThreshold: Int?) async throws -> CTMResponses.Activation
    func checkIn() async throws -> CTMResponses.CheckIn
    func snooze() async throws -> CTMResponses.Snooze
}

final class CTMRepository: CTMRepositoryType {
    private let client: NetworkClientType

    init(client: NetworkClientType) {
        self.client = client
    }

    func activate(messageId: String, checkinIntervalDays: Int?, releaseThreshold: Int?) async throws -> CTMResponses.Activation {
        let body = CTMRequests.Activate.Body(checkinIntervalDays: checkinIntervalDays, releaseThreshold: releaseThreshold)
        let res: BaseResponse<CTMResponses.Activation> = try await client.request(CTMRequests.Activate(messageId: messageId, body: body))
        return res.data
    }

    func checkIn() async throws -> CTMResponses.CheckIn {
        let res: BaseResponse<CTMResponses.CheckIn> = try await client.request(CTMRequests.CheckIn())
        return res.data
    }

    func snooze() async throws -> CTMResponses.Snooze {
        let res: BaseResponse<CTMResponses.Snooze> = try await client.request(CTMRequests.Snooze())
        return res.data
    }
}
