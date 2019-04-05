import Foundation

let workQueue = DispatchQueue(label: "app.cakewallet.work-queue", qos: .default, attributes: DispatchQueue.Attributes.concurrent)
let updateQueue = DispatchQueue(label: "app.cakewallet.update-queue", qos: .background, attributes: DispatchQueue.Attributes.concurrent)
let fileDownloadingQueue = DispatchQueue(label: "app.cakewallet.fileDownloadingQueue", qos: .default, attributes: DispatchQueue.Attributes.concurrent)
