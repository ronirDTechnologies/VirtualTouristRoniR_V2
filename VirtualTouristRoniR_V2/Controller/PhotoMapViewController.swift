//
//  PhotoMapViewController.swift
//  VirtualTouristRoniR_V2
//
//  Created by Roni Rozenblat on 1/12/22.
//

import Foundation
import MapKit
import CoreData
private let reuseIdentifier = "PhotoCell"




class PhotoMapViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,MKMapViewDelegate, NSFetchedResultsControllerDelegate
{

  @IBOutlet weak var MapSelectedLocationMKView: MKMapView!
  @IBOutlet weak var PhotoCollectionView: UICollectionView!
  @IBOutlet weak var NoPhotoLabel: UILabel!
  @IBOutlet weak var RequestNewCollectionBtn: UIButton!
  var photoAddedCnt = 0
  var totalPhotoCnt = 0
  public var latVal:String = "0.0"
  public var lonVal:String = "0.0"
  var pin:Pin!
  var dataController: DataController!
  //var fetchedResultsController:NSFetchedResultsController<Pin>!
  var fetchedResultsController:NSFetchedResultsController<PhotoInfo>!
  
  func setupFetchedResultsController(){
    //let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
    let fetchRequest:NSFetchRequest<PhotoInfo> = PhotoInfo.fetchRequest()
    let sortDescriptor = NSSortDescriptor(key: "lat", ascending: false)
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    //let predicate = NSPredicate(format: "lat == %lf AND lon == %lf", pin.lat, pin.lon )
    //
    let predicate = NSPredicate(format: "pin == %@",pin)
    fetchRequest.predicate = predicate
    //let latNum = NSNumber.init(value: pin.lat)
    
    //let longNum = NSNumber.init(value: pin.lon)
    
    //let predicateLatitude = NSPredicate(format: "lat == %@", latNum)
    //let predicateLongtitude = NSPredicate(format: "lon == %@", longNum)
    
    //let andPred = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicateLatitude,predicateLongtitude])
    //
    print("THIS IS THE PASSED IN PIN LAT \(pin.lat)")
    print("THIS IS THE PASSED IN PIN LON \(pin.lon)")
            
        
    //fetchRequest.predicate = andPred
    
    fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    
    fetchedResultsController.delegate = self
    
    do{
      try fetchedResultsController.performFetch()
      print("THE NUMBER OF PICTURES RETURNED WITH THIS PIN () \(pin.photos?.count ?? 0)")
      print("THE NUMBER OF PICTURES RETURNED FROM THE FETCH RESULTS CONTROLLER \(fetchedResultsController.fetchedObjects!.count)")
    } catch{
      fatalError("The fetch could not be performed: \(error.localizedDescription)")
    }
    
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupFetchedResultsController()
    
    // TODO: 01-17-2022 Check to see if there are any photo's returned in the PIN, if not start a new download
    if fetchedResultsController.sections![0].numberOfObjects == 0 {
      print("NO PICTURES WHERE FOUND IN CORE DATA.  GO AND DOWNLOAD PICS USING LAT: \(latVal) AND LON: \(lonVal)")
      downloadPicsFromApi(pinLatVal: latVal, pinLonVal: lonVal)
    }
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupFetchedResultsController()
  }
  func downloadPicsFromApi(pinLatVal: String, pinLonVal: String){
    print("STARTING DOWNLOAD PICS FROM FLICKER API")
    RequestNewCollectionBtn.isEnabled = false
    let pinLatValCLLC = Double(pinLatVal)! as Double
    let pinLongValCCLC = Double(pinLonVal)! as Double
    let centerPt = CLLocationCoordinate2D.init(latitude: pinLatValCLLC, longitude: pinLongValCCLC)
    let region = MKCoordinateRegion.init(center: centerPt, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
    let annotation = MKPointAnnotation()
    annotation.coordinate = centerPt
    
    self.MapSelectedLocationMKView.addAnnotation(annotation)
    
    self.MapSelectedLocationMKView.setRegion(region, animated: true)
    DispatchQueue.global(qos: .userInitiated).async {
      VirtualTouristClient.GetPhotosForLatLon(latVal: pinLatVal, lonVal: pinLonVal)
      {
          (data,error) in guard let data = data else
          {
              return
          }
          
          if data.photo.count > 0
          {
              self.totalPhotoCnt = data.photo.count
              print("THE NUMBER OF PHOTOS RETURNED FOR PIN ARE  ==>  \(data.photo.count)")
        
          for pht in data.photo{
            self.addPhoto(imageVal: pht.id, imageUrlStr: pht.urlT)
          }
              //self.pinPhotoInfo = data.photo
              // TODO 12-12-2020 LOAD PICS INTO CORE DATA
              
              //try? self.loadPicsIntoCD(pinPhotoInfoArray: self.pinPhotoInfo)
              self.PhotoCollectionView.reloadData()
          }
          else
          {
              self.NoPhotoLabel.isHidden = false
          }
      }
                    
                    
            
                    print("DATA TEST")
                    //print("ERROR 3\(error?.localizedDescription)")
                    //print("ERROR 4\(error)")
        
    }
    
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
    fetchedResultsController.sections?[0].numberOfObjects ?? 0
  }

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
  let picInfo = fetchedResultsController.object(at: indexPath)
  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! locationPicCell
  
  
  
  return cell
}

  /*
      Will add a photo to coredata
   */
  func addPhoto(imageVal: String, imageUrlStr: String){
    
    let imageUrl:URL = URL(string: imageUrlStr)!
    guard let imageData:NSData = NSData(contentsOf: imageUrl) else{
        return
    }
    
    let photo = PhotoInfo(context: dataController.viewContext)
    photo.pin = pin
    photo.image = imageData as Data
    photo.url_t = imageUrl

    try? dataController.viewContext.save()
    print("SAVED PHOTO TO CORE DATA \(pin!)")
  }
    
/*
  Will show the map at the top half of the page of where the user clicked on the pin
 */
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        
    let reuseId = "pin"
        
    var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
    
    if pinView == nil
    {
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView!.canShowCallout = true
        pinView!.pinTintColor = .red
        pinView?.animatesDrop = true
    }
    
    else
    {
        pinView!.annotation = annotation
    }
    
    return pinView
  }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
}
