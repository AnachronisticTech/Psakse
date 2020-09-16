//
//  Puzzle.swift
//  Psakse
//
//  Created by Daniel Marriner on 15/09/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import Foundation

struct Puzzle: Codable {
    var numID: Int
    var id: String
    var properties: String
    
    static func sendToServer(puzzleConfiguration string: String) {
        guard let location = Bundle.main.url(forResource: "link", withExtension: "txt") else { return }
        guard let tmp = try? String(contentsOf: location), tmp != "" else { return }
        let url = URL(string: tmp.trimmingCharacters(in: .newlines))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let data = "string=\(string)"
        request.httpBody = data.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
    
    static func fetchAll(then handler: (([Puzzle]) -> Void)? = nil) {
        let debug = false
        if debug {
            guard let location = Bundle.main.url(forResource: "link", withExtension: "txt") else { return }
            guard let tmp = try? String(contentsOf: location), tmp != "" else { return }
            let url = URL(string: tmp.trimmingCharacters(in: .newlines))!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print(error)
                } else if let data = data {
                    let decoder = JSONDecoder()
                    let decodedData = try! decoder.decode([Puzzle].self, from: data)
                        .sorted { $0.numID < $1.numID }
                    if let handler = handler {
                        handler(decodedData)
                    }
                }
            }
            task.resume()
        } else {
            let puzzles = [
                Puzzle(numID: 1,  id: "f2f3906381e4e9813678b0ca4934afb4fd97d012", properties: "01ye09pe16yp11221201001122222"),
                Puzzle(numID: 2,  id: "2bc30c7b09f20fd95246fc6a42a4b95c82f5d6a7", properties: "04pp13yp19ge11111212112211022"),
                Puzzle(numID: 3,  id: "40a8b5004dc40392118412e229f02162e79c6645", properties: "06pp16ox19pa01222111112112112"),
                Puzzle(numID: 4,  id: "e98c72819ac06b5c9f0185417533250d7044d45f", properties: "11gx15pe17pp20112222112102102"),
                Puzzle(numID: 5,  id: "f0bc0186c4a0f474cd39682358d7bd0f73a87f04", properties: "01pe05op16ga10121212121111122"),
                Puzzle(numID: 6,  id: "51ebae00f15e9750c2323379af1cf0e181e7b86f", properties: "07yp13yx17ga21001200122222212"),
                Puzzle(numID: 7,  id: "30c211163fc86cead639b00197247de965954c1d", properties: "03ga06pe19gx11112211012012222"),
                Puzzle(numID: 8,  id: "80baee2300dfb2f9da68b87f56cd32432aabb0ac", properties: "10oa14ye17ox22121220121210102"),
                Puzzle(numID: 9,  id: "b68edc12f7e06e72f29d7174808e9bc1c08986ff", properties: "02gx09pa11pp21121112112111022"),
                Puzzle(numID: 10, id: "56662fa2773c5a98c8822b589b9d70f9a8c7dcd2", properties: "04pa10gx20op02022222011102212"),
                Puzzle(numID: 11, id: "88c149de22ebdfb9dc7af7d7aaf71c92faf295ca", properties: "10px13yp24ya11211011111222122"),
                Puzzle(numID: 12, id: "bfe09261ea4c1f067530d307fa8ef560114b8327", properties: "06gx13pa16ye21110121212212102"),
                Puzzle(numID: 13, id: "40d3e0cd3242193d3913d54b274c4edf0c09b67a", properties: "07pp18pa24pe12211220011121122"),
                Puzzle(numID: 14, id: "b8042e77c678a26c6dd2288069ccddbaa9f1b460", properties: "04pa11ox20pe22111212111112102"),
                Puzzle(numID: 15, id: "124c71bc3bfc5068dbf846ae839b255382969e4d", properties: "07ga14yx16pe20221202110112212"),
                Puzzle(numID: 16, id: "6722446798804a24c7008793d831a179926a1093", properties: "04pe12oe19oa22211212101111112"),
                Puzzle(numID: 17, id: "ef66c26826bcb4bfba98968050ba655928492f5f", properties: "20oe22gp24pe01222211212020112"),
                Puzzle(numID: 18, id: "8bfa78496505da8236cd6466c621d578901a0e99", properties: "04ga14ox20ge20111112121112122"),
                Puzzle(numID: 19, id: "26f371d4425624459c7ca50dbf6de1e7129df533", properties: "11op14pa20gp11121221202102112"),
                Puzzle(numID: 20, id: "25c3b784567f86a6e83d5e02667bffa7beb7c547", properties: "04oe10px19gx01120112221212202"),
                Puzzle(numID: 21, id: "2d6eeeecb5ed1b715dbe598577fcb3c9f2f338d6", properties: "07gp09yx23ye02221110022122112"),
                Puzzle(numID: 22, id: "deb54ee245dd813cfe76747dc96873c3d20028fe", properties: "09px21ge23gx22012112121210112"),
                Puzzle(numID: 23, id: "f1c34d1e2b41a4acaa5861cfd4a7f12fdb3640f7", properties: "13ya21pa23ye12222111200111212"),
                Puzzle(numID: 24, id: "203b4100ebeeb7428f4d421d19a78ad4f60d1b20", properties: "15px19gx21pp22102112021111212"),
                Puzzle(numID: 25, id: "573d3d96fb257844fbf11189a958828f3bfdb58b", properties: "04oa10gp22oa11222021111110222"),
                Puzzle(numID: 26, id: "87a3247790a4c799912f8ffbb57d122ff7174774", properties: "16ge20ya22yp11211111120211222"),
                Puzzle(numID: 27, id: "48631110af0366bf1a2555f2d0e9eac8c5e65bfb", properties: "12ga16ge18yx01102212112202212"),
                Puzzle(numID: 28, id: "ef9895fc729b64d0f342e99af1ccab04806f1ff5", properties: "03ye18oe22ox22221110211112012"),
                Puzzle(numID: 29, id: "dbce29ecd44dc14064b7bf1120f14675d189281c", properties: "01ga19gx21ye10111211111222212"),
                Puzzle(numID: 30, id: "1474ceebb47bc6f48bc82b658290ee45b19cd6d8", properties: "08op11yp14gx12110122221101212")
            ]
            if let handler = handler { handler(puzzles) }
        }
    }
}
