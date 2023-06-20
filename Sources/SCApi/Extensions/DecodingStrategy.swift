import Foundation

extension JSONDecoder.DateDecodingStrategy {
    static let customISO8601 = custom { decoder throws -> Date in
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        if let date = DateFormatter.iso8601.date(from: string) ?? DateFormatter.iso8601noFS.date(from: string) {
            return date
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
    }
}

extension JSONEncoder.DateEncodingStrategy {
    static let customISO8601 = custom { date, encoder throws in
        let dateString = DateFormatter.iso8601.string(from: date)
        var container = encoder.singleValueContainer()
        try container.encode(dateString)
    }
}
