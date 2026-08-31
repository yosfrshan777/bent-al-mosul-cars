from fastapi import APIRouter

router = APIRouter()
BRANDS = [
 ('Toyota','تويوتا'),('BMW','BMW'),('Mercedes-Benz','مرسيدس'),('Audi','أودي'),('Lexus','لكزس'),
 ('Kia','كيا'),('Hyundai','هيونداي'),('Nissan','نيسان'),('Ford','فورد'),('Chevrolet','شيفروليه'),
 ('Honda','هوندا'),('Mazda','مازدا'),('Volkswagen','فولكسفاغن'),('Porsche','بورشه'),('Jeep','جيب'),
 ('Land Rover','لاند روفر'),('Range Rover','رينج روفر'),('Mitsubishi','ميتسوبيشي'),('Subaru','سوبارو'),('Suzuki','سوزوكي'),
 ('Chery','شيري'),('Geely','جيلي'),('MG','MG'),('GAC','GAC'),('BYD','BYD')
]

@router.get('/brands')
def brands():
    return [{'id': i + 1, 'name': en, 'name_ar': ar, 'logo': f'/api/brands/{i + 1}/logo'} for i,(en,ar) in enumerate(BRANDS)]

@router.get('/brands/{brand_id}/logo')
def brand_logo(brand_id: int):
    # The client can resolve a bundled/local logo by stable brand id.
    if brand_id < 1 or brand_id > len(BRANDS):
        return {'logo': None}
    return {'brand': BRANDS[brand_id-1][0], 'asset': f'assets/brands/{BRANDS[brand_id-1][0].lower().replace(" ", "-")}.png'}
