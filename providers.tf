terraform{


    required_providers{
       
       local = {

            source = "hashicorp/local"
            version = "2.6"

       }

       random = {
       source = "hashicorp/random" 
       version = "3.1"

       }


    }
}