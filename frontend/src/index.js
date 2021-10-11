import "./index.css";
const base_url = "http://localhost:3001/" 

var myHeaders = new Headers();
var myInit = { method: 'GET',
               headers: myHeaders,
               mode: 'cors',
               cache: 'default' };

fetch('http://localhost:3001/cars.json', myInit)
.then(function(response) {
  return response.json();
})
.then(function(data) {
    console.log(data[0]);
    data.map((car)=>{
        createCarElement(car)
    })
});
const distances = Array.from({length: 60}, (_, i) => (i + 1) * 50)
distances.forEach((distance)=>{
    let option = document.createElement('option');
    option.value = distance
    option.innerHTML = distance
    document.getElementById("distance").append(option);

})

const createImgBlock = (car) => {
    let imgContainer = document.createElement('div');
    imgContainer.className = "img-container"
    let carImg = document.createElement('img');
    carImg.className = "car-img"
    carImg.src = base_url + car.picturePath
    imgContainer.appendChild(carImg)

    return imgContainer;
}
const createCarElement = (car, duration = null, distance = null) => {
    let carContainer = document.createElement('div');
    carContainer.className = "car-container"
    carContainer.append(createImgBlock(car));
    let titleContainer = document.createElement('h2');
    titleContainer.className = "car-title"
    titleContainer.innerHTML = `${car.brand} : ${car.model}`
    let priceContainer = document.createElement('div');
    priceContainer.className = "price-container"    
    let priceKmContainer = document.createElement('div');
    priceKmContainer.className = "price-km price"
    priceKmContainer.innerHTML = `${car.pricePerKm} €/Km`
    let priceDayContainer = document.createElement('div');
    priceDayContainer.className = "price-day price"
    priceDayContainer.innerHTML = `${car.pricePerDay} €/Day`

    let detailContainer = document.createElement('div');
    detailContainer.className = "detail-container"
    let price = 0;
    if(duration){
        price += (car.pricePerDay * duration)
    }

    if(distance){
        price += (car.pricePerKm * distance)
    }
    let rentalContainer = document.createElement('div');
    rentalContainer.className = "rental-price"
    rentalContainer.innerHTML = `Rental Price : ${price} €`

    priceContainer.append(priceKmContainer)
    priceContainer.append(priceDayContainer)
    detailContainer.append(titleContainer)
    detailContainer.append(priceContainer)
    if(price != 0){
        detailContainer.append(rentalContainer)
    }
    carContainer.append(detailContainer)
    document.getElementById("cars").append(carContainer);
}
const fetchCars = (e) => {
    let params = {}
    let duration = document.getElementById("duration").value 
    let distance = document.getElementById("distance").value 
    if(duration == ""){
        params["duration"] = duration
    }

    if(distance == ""){
        params["distance"] = distance
    }
    let queryParams = objToQuery({duration, distance})
    fetch(`http://localhost:3001/cars.json?${queryParams}`, myInit)
    .then(function(response) {
        return response.json();
    })
    .then(function(data) {
        document.getElementById("cars").innerHTML = ""
        data.map((car)=>{
            createCarElement(car, duration, distance)
        })
    });
}

document.getElementById("duration").addEventListener("keyup", fetchCars)
document.getElementById("distance").addEventListener("change", fetchCars)

const objToQuery = (obj) => {
    return Object.keys(obj).map(key => key + '=' + obj[key]).join('&');
}