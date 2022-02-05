//
//  PhotoAlMapViewController.swift
//  VIrtualTourist_RoniR
//
//  Created by Roni Rozenblat on 3/2/20.
//  Copyright © 2020 dinatech. All rights reserved.
//

import UIKit
import MapKit
import CoreData
private let reuseIdentifier = "PhotoCell"


class PhotoAlMapViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,MKMapViewDelegate, NSFetchedResultsControllerDelegate
{
    @IBOutlet weak var MapSelectedLocationMKView: MKMapView!
    @IBOutlet weak var RequestNewCollectionBtn: UIButton!
    @IBOutlet weak var PhotoCollectionView: UICollectionView!
    @IBOutlet weak var NoPhotoLabel: UILabel!
    
    var photoAddedCnt = 0
    var totalPhotoCnt = 0
    var pinPhotoInfo: [Photo] = []
    var dataController: DataController!
    var pin:Pin!
    var fetchedResultsControllerPin:NSFetchedResultsController<Pin>!
    
    public var latVal:String = "0.0"
    public var lonVal:String = "0.0"
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        fetchedResultsControllerPin = nil
    }
    override func viewWillAppear(_ animated: Bool) {
            //loadPicsForLatLon(pinLatVal: "40", pinLonVal: "40")
        //var picsExist =  doPicsExistForPin()
        //let pinExists = doesPinExist()
        let pinExists = doPicsExistForPin()
        loadPicsForLatLon(pinLatVal: latVal, pinLonVal: lonVal, pinExists: pinExists)
    }
    // TODO: 09-11-2020
    /*  Will search for photos attached to pin.  If none return false
     */
    func doPicsExistForPin() -> Bool
    {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let predicate = NSPredicate(format: "lat == %lf AND lon == %lf", pin.lat, pin.lon )

        print("THIS IS THE PASSED IN PIN LAT \(pin.lat)")
        print("THIS IS THE PASSED IN PIN LON \(pin.lon)")
                
            
        fetchRequest.predicate = predicate
            
        if let result = try? dataController.viewContext.fetch(fetchRequest).first
        {
            print("NUMBER OF PHOTOS RETURNED \( result.photos?.count ?? 0)" )
                
            if result.photos?.count ?? 0 > 0
            {
                return true
            }
            
        }
           
            return false
      
        
    }
    /*func doesPinExist() -> Bool
    {
              
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let predicate = NSPredicate(format: "lat == %f AND lon == %f", pin.lat, pin.lon )

        print("THIS IS THE PASSED IN PIN LAT \(pin.lat)")
        print("THIS IS THE PASSED IN PIN LON \(pin.lon)")
                
            
        fetchRequest.predicate = predicate
            
        if let result = try? dataController.viewContext.fetch(fetchRequest).first
        {
            print("NUMBER OF PHOTOS RETURNED \(result.photos!.count)" )
            //print("NUMBER OF PHOTOS RETURNED FOR PIN \(result.pin)")
                
            if result.photos?.count ?? 0 > 0
            {
                return true
            }
            
        }
           
            return false
      
    }*/
    func doPicsExistInDataStoreForPin() -> Bool
    {
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let predicate = NSPredicate(format: "lat == %lf AND lon == %lf", pin.lat, pin.lon )

        print("THIS IS THE PASSED IN PIN LAT \(pin.lat)")
        print("THIS IS THE PASSED IN PIN LON \(pin.lon)")
            
        
        fetchRequest.predicate = predicate
        
        if let result = try? dataController.viewContext.fetch(fetchRequest).first
        {
            print("NUMBER OF PHOTOS RETURNED \(result.photos!.count)" )
            
            if result.photos?.count ?? 0 > 0
            {
                return true
            }
        
        }
        
        return false
        
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
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
    
    func loadPicsIntoCD(pinPhotoInfoArray:[Photo]) throws
    {
        pinPhotoInfoArray.forEach {photoInfoObj in
        
            self.pin.photos?.adding(photoInfoObj)
            
            let pinCD = Pin(context: dataController.viewContext)
            
            pinCD.photos = pin.photos
            do {
                try dataController.viewContext.save()
                
            }
            catch{print("ERROR OCCURED WHILE TRYING TO SAVE : \(error)" )}
        }
        // Move to above 01-02-2022 try? dataController.viewContext.save()
        
    }
    func loadPicsForLatLon(pinLatVal: String, pinLonVal: String, pinExists:Bool){
            RequestNewCollectionBtn.isEnabled = false
            let pinLatValCLLC = Double(pinLatVal)! as Double
            let pinLongValCCLC = Double(pinLonVal)! as Double
            let centerPt = CLLocationCoordinate2D.init(latitude: pinLatValCLLC, longitude: pinLongValCCLC)
            let region = MKCoordinateRegion.init(center: centerPt, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                
            let annotation = MKPointAnnotation()
            annotation.coordinate = centerPt
            
            self.MapSelectedLocationMKView.addAnnotation(annotation)
            self.MapSelectedLocationMKView.setRegion(region, animated: true)
                DispatchQueue.global(qos: .userInitiated).async
                {
                        VirtualTouristClient.GetPhotosForLatLon(latVal: pinLatVal, lonVal: pinLonVal)
                        {
                            (data,error) in guard let data = data else
                            {
                                return
                            }
                            
                            if data.photo.count > 0
                            {
                                self.totalPhotoCnt = data.photo.count
                                self.pinPhotoInfo = data.photo
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
            //}
            

                      
         
           
        }
    fileprivate func setupFetchedResultsController() {
        // TODO: 02-07-2021 Setup Fetch Request
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
       
        let predicate = NSPredicate(format: "lat == %lf AND lon == %lf", pin.lat, pin.lon )

        print("THIS IS THE PASSED IN PIN LAT \(pin.lat)")
        print("THIS IS THE PASSED IN PIN LON \(pin.lon)")
            
        
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "lat", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsControllerPin = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsControllerPin.delegate = self
        do{
            try fetchedResultsControllerPin.performFetch()
            print("THE NUMBER OF RESULTS RETURNED ==> \(String(describing: fetchedResultsControllerPin.fetchedObjects?.count))")
            
            if fetchedResultsControllerPin.fetchedObjects?.count == 0 {
                let pinValue = Pin(context: dataController.viewContext)
                pinValue.lat = pin.lat
                pinValue.lon = pin.lon
                
                try? dataController.viewContext.save()
            }
        }
        catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //
        setupFetchedResultsController()
        // End Fetch Request
        
        //self.loadPicsForLatLon(pinLatVal: latVal, pinLonVal: lonVal,pinExists: true)
        
        
        
        
        // Do any additional setup after loading the view.
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return pinPhotoInfo.count 
    }
      
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        //print("THIS IS THE NUMBER OF RETURNED RESULTS \(fetchedResultsControllerPin.fetchedObjects?.count ?? 0)")
       // let aPhoto = fetchedResultsControllerPin.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)  as! locationPicCell
        
        let activityView = UIActivityIndicatorView(style: .medium)
        

        //cell.cellImageVal.addSubview(fadeView)

        cell.addSubview(activityView)
        activityView.hidesWhenStopped = true
        activityView.frame = cell.bounds
        //activityView.center = cell.view.center
        
        /*
         * 06-27-2021
         * Get from pin photo Info array
         */
        guard let url = URL(string: self.pinPhotoInfo[indexPath.row].urlT) else { return cell }
        
        
        cell.cellImageVal.image = nil // set(image: nil)
                 
        DispatchQueue.global().async
        {
            let data = try? Data(contentsOf: url)
                     
            if let data = data, let image = UIImage(data: data)
            {
                
                DispatchQueue.main.async
                {
                    
                    cell.cellImageVal.image = image
                    //cell.cellImageVal.image = image
                    activityView.stopAnimating()
                }
            }
        }
                 
                 
                 
                 
                 if pinPhotoInfo.count > 0
                 {
                     
                      activityView.startAnimating()
                     // Start background thread so that image loading does not make app unresponsive
                     
                        DispatchQueue.global(qos: .userInitiated).async
                     {
                        let tempPhoto = self.pinPhotoInfo[indexPath.row]
                        let imageUrl:URL = URL(string: tempPhoto.urlT)!
                        guard let imageData:NSData = NSData(contentsOf: imageUrl) else{
                            return
                        }
                        
                        guard let cellImageVal = UIImage(data: imageData as Data) else {
                                                                     return
                                    }
                        // TODO 09-05-2020 ADD PHOTOS TO PIN IN COREDATA
                        let photoInfo = PhotoInfo(context:self.dataController.viewContext)
                        // 01-02-2022 SAVE Context
                        photoInfo.url_t = imageUrl
                        photoInfo.image = imageData as Data
                        
                        // When from background thread, UI needs to be updated on main_queue
                        DispatchQueue.main.async
                        {
                            self.photoAddedCnt = self.photoAddedCnt + 1
                            if self.totalPhotoCnt == self.photoAddedCnt {
                                self.RequestNewCollectionBtn.isEnabled = true
                            }
                            
                            
                            activityView.stopAnimating()
                            activityView.isHidden = true
                            cell.cellImageVal.image = cellImageVal
                            
                            self.addPhoto(imageVal: imageData as Data, imageUrlVal: imageUrl)
                         
                         }
                     }
                 }
        
        
                 return cell
             
      }
    func addPhoto(imageVal: Data, imageUrlVal:URL)
    {
        let photo = PhotoInfo(context: dataController.viewContext)
         photo.pin = pin
         photo.image = imageVal as Data
         photo.url_t = imageUrlVal
        
         try? self.dataController.viewContext.save()
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //print("NUMBER OF SECTIONS ==> \(fetchedResultsControllerPin.sections?.count ?? 1)")
        return  1//fetchedResultsControllerPin.sections?.count ?? 1
    }

    //
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? PhotoAlbumViewController {
            vc.dataController = dataController
        }
    }*/
    

}
