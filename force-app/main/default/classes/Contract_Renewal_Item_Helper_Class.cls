/*********************************************************************
* Description      : This class is used for handling new pricing logic
* Test Class       : Contract_Renewal_Test
* Author(s)        : Dun Silver
**********************************************************************/
public with sharing class Contract_Renewal_Item_Helper_Class {
			public Contract_Renewal_Item_Helper_Class() {
					//constructor
			}

/********************* Below used to Identify BU products at the Header level using Product_Class__c field ****************
Grouping 00-Urology, 01-Alt Site, 02-Anesthesia, 03-OEM, 04-Respiratory, 05-Surgical, 06-Critical Care, 07-GPO, 08-IDN,
09-Distribution, 10-Dialysis, 11-Specialty Markets, 12-Vascular Access, 13-Interventional, 14-Cardiac, 15-Cross Divisional
**************************************************************************************************************************/

			//function to handle pricing logic
			public static void pricingLogicCheck(List<Contract_Renewal_Item__c> newTrigger){
					System.debug('*** Running pricingLogicCheck method in Contract_Renewal_Item_Helper_Class ***');
					Map<String, Business_Unit__c> buMap = Business_Unit__c.getAll();
					Set<Contract_Renewal_Item__c> criList = new Set<Contract_Renewal_Item__c>();
					List<Contract_Renewal_Item__c> criUpdList = new List<Contract_Renewal_Item__c>();
					List<Contract_Renewal_Item__c> criRecs = new List<Contract_Renewal_Item__c>();

					criRecs = [SELECT Id, Name, Product__r.Sbu__c, Product__r.Group__c, Product__r.SubGroup__c, Product__r.Class__c, Product__r.Description,
										Product__r.Brand_Name__c, Product__r.Floor_Price__c, Product__r.Name, Product__r.Product_Class__c, Contract_Renewal__r.Group__c,
										Default_Renewal_Price__c, Product__r.Director_Price__c, Product__r.RSM_Price__c, Product__r.Rep_Price__c
										FROM Contract_Renewal_Item__c
										WHERE Id IN:newTrigger];

					for(Contract_Renewal_Item__c curr : criRecs){
							//logic for Anesthesia
							String prodName = curr.Product__r.Name;
							String prodSBU = curr.Product__r.SBU__c;
							String classBu = curr.Product__r.Class__c;
							String descrp = curr.Product__r.Description;
							System.debug('*** prodName *** ' + prodName);
							System.debug('*** curr.Product__r.Class__c *** ' + curr.Product__r.Class__c);

							//start Anesthesia price check
							if(curr.Product__r.Class__c == 'Anesthesia'){
									System.debug('*** Anesthesia Product ***');
							    //pricing logic
									//pricing for Airway products 3%
									if(curr.Product__r.Group__c == 'Airway'){
											System.debug('*** Anesthesia Product / Airway ***');
											curr.Default_Renewal_Price__c = airwaysPricing(curr.Default_Renewal_Price__c);
											criList.add(curr);
									}

									//pricing for Regional Anesthesia 4%
									if(curr.Product__r.Group__c == 'Regional Anesthesia'){
											System.debug('*** Anesthesia Product / Regional Anesthesia ***');
											curr.Default_Renewal_Price__c = regionalAnesPricing(curr.Default_Renewal_Price__c);
											criList.add(curr);
									}

									//pricing for LMA products to floor
									if(curr.Product__r.Brand_Name__c == 'LMA' && curr.Default_Renewal_Price__c < curr.Product__r.Floor_Price__c){
											System.debug('*** Anesthesia Product / LMA And Below Floor ***');
											curr.Default_Renewal_Price__c = curr.Product__r.Floor_Price__c;
											criList.add(curr);
									}
									//pricing for MAD products to floor
									if(prodName.containsIgnoreCase('MAD') && curr.Default_Renewal_Price__c < curr.Product__r.Floor_Price__c){
											System.debug('*** Anesthesia Product / MAD And Below Floor ***');
											curr.Default_Renewal_Price__c = curr.Product__r.Floor_Price__c;
											criList.add(curr);
									}
							}//end of Anesthesia check

							//logic for Alt Site
							if(curr.Contract_Renewal__r.Group__c == '01' ){
								//pricing logic
								curr.Default_Renewal_Price__c = pricingLogic(curr.Default_Renewal_Price__c);
								criList.add(curr);
							}


                        if(classBu != NULL){
                            if(classBu.containsIgnoreCase('Interventional') ){
                                //pricing logic
                                curr.Default_Renewal_Price__c = interventionalProds(curr.Default_Renewal_Price__c);
                                criList.add(curr);
                            }

                            //logic for Interventional Capital
                            if(classBu.containsIgnoreCase('Cardiac') ){
                                //pricing logic
                                if(curr.Default_Renewal_Price__c < curr.Product__r.Rep_Price__c && curr.Default_Renewal_Price__c >= curr.Product__r.RSM_Price__c){
                                    curr.Default_Renewal_Price__c = curr.Product__r.Rep_Price__c;
                                    criList.add(curr);
                                }
                                else if(curr.Default_Renewal_Price__c < curr.Product__r.RSM_Price__c && curr.Default_Renewal_Price__c >= curr.Product__r.Director_Price__c){
                                    curr.Default_Renewal_Price__c = curr.Product__r.RSM_Price__c;
                                    criList.add(curr);
                                }
                                else{
                                    curr.Default_Renewal_Price__c = curr.Product__r.Director_Price__c;
                                    criList.add(curr);
                                }
                            }

                            //logic for Respiratory
                            if(classBu == 'Respiratory'){
                                System.debug('*** Respiratory Product ***');
                                //pricing logic
                                curr.Default_Renewal_Price__c = pricingLogic(curr.Default_Renewal_Price__c);
                                criList.add(curr);
                            }

                            //logic for Vascular
                            if(classBu.containsIgnoreCase('Vascular') ){
                                System.debug('*** Vascular Product ***');
                                //raise Arterials to floor
                                if(curr.product__r.SubGroup__c == 'Arterials' && curr.Default_Renewal_Price__c < curr.Product__r.Floor_Price__c){
                                    curr.Default_Renewal_Price__c = curr.Product__r.Floor_Price__c;
                                    criList.add(curr);
                                }
                                else{
                                    //4% increase on Vascular Prods
                                    curr.Default_Renewal_Price__c = vascularProds(curr.Default_Renewal_Price__c);
                                    criList.add(curr);
                                }

                            }

                            //logic for Surgical... removed SBU check as it doesn't have values for all products
                            //if(curr.Product__r.SBU__c == 'Surgical'){
                            //Access - Closure pricing logic
                            if(curr.Product__r.Class__c == 'Access' && curr.Product__r.Group__c == 'Closure'){
                                curr.Default_Renewal_Price__c = accessClosure(curr.Default_Renewal_Price__c);
                                criList.add(curr);
                            }

                            //Automatic Polymer pricing logic
                            if(curr.Product__r.Group__c == 'Polymer' && curr.Product__r.SubGroup__c == 'Auto'){
                                curr.Default_Renewal_Price__c = autoPolymer(curr.Default_Renewal_Price__c);
                                criList.add(curr);
                            }

                            //Cholangiography pricing logic
                            if(curr.Product__r.Group__c == 'Cholangiography'){
                                curr.Default_Renewal_Price__c = cholangiography(curr.Default_Renewal_Price__c);
                                criList.add(curr);
                            }

                            //Conduit Harvesting pricing logic
                            if(curr.Product__r.Group__c == 'Conduit Harvesting'){
                                curr.Default_Renewal_Price__c = conHarvesting(curr.Default_Renewal_Price__c);
                                criList.add(curr);
                            }

                            //logic for Surgical MemoBag
                            if(descrp.containsIgnoreCase('MemoBag') ){
                                //2.5% increase
                                curr.Default_Renewal_Price__c = memobag(curr.Default_Renewal_Price__c);
                                criList.add(curr);

                            }

                            //logic for Surgical Metal Appliers
                            if(descrp.containsIgnoreCase('Applier') && curr.Product__r.Group__c == 'Metal' ){
                                //make price $415.00
                                if(curr.Default_Renewal_Price__c != 99.00){
                                    curr.Default_Renewal_Price__c = metalAppliers(curr.Default_Renewal_Price__c);
                                    criList.add(curr);
                                }
                            }

                            //Metal Clip Remov.Forcep 10.5... some records do not have an SBU
                            if( descrp.containsIgnoreCase('Metal Clip Remov.Forcep 10.5') ){
                                if(curr.Default_Renewal_Price__c != 199.00){
                                    curr.Default_Renewal_Price__c = metalClip105(curr.Default_Renewal_Price__c);
                                    criList.add(curr);
                                }

                            }

                            //Metal Clip Remov.Forcep 6.5... some records do not have an SBU
                            if( descrp.containsIgnoreCase('Metal Clip Remov.Forceps 6.5') ){
                                if(curr.Default_Renewal_Price__c != 199.00){
                                    curr.Default_Renewal_Price__c = metalClip65(curr.Default_Renewal_Price__c);
                                    criList.add(curr);
                                }

                            }

                            //logic for miniLap... some miniLap records do not have an SBU
                            if( curr.Product__r.Brand_Name__c == 'miniLap' || curr.Product__r.Class__c == 'miniLap'){
                                curr.Default_Renewal_Price__c = miniLap(curr.Default_Renewal_Price__c);
                                criList.add(curr);
                            }

                            //logic for Percuvance... some Percuvance records do not have an SBU
                            if( curr.Product__r.Brand_Name__c == 'Percuvance' ){
                                curr.Default_Renewal_Price__c = percuvance(curr.Default_Renewal_Price__c);
                                criList.add(curr);
                            }

                            //logic for Surgical Skin Stapling... some Skin Stapling records do not have an SBU
                            if(curr.Product__r.Group__c == 'Skin Stapling'){
                                curr.Default_Renewal_Price__c = skinStapling(curr.Default_Renewal_Price__c);
                                criList.add(curr);
                            }

                            //logic for Surgical Skin Stapling... some Skin Stapling records do not have an SBU
                            if(descrp.containsIgnoreCase('STERILITY/STORAGE TRAY') ){
                                //make price $415.00
                                if(curr.Default_Renewal_Price__c != 415.00){
                                    curr.Default_Renewal_Price__c = sterStorageTray(curr.Default_Renewal_Price__c);
                                    criList.add(curr);
                                }
                            }

                            //logic for Surgical Skin Stapling... some Skin Stapling records do not have an SBU
                            if( descrp.containsIgnoreCase('Trocars') ){
                                curr.Default_Renewal_Price__c = trocars(curr.Default_Renewal_Price__c);
                                criList.add(curr);
                            }
                            // End Pricing Logic
                        }

							//add changes to list for bulk updating
							//criList.add(curr);
					}//end of for loop

					System.debug('*** criList.size() *** ' + criList.size() );

					//check list size and update items
					if(criList.size() > 0){
							criUpdList.addAll(criList);
							System.debug('*** Updating criList ***');
							update criUpdList;
					}
            }//end of public static void pricingLogic

			//parent function to handle standard pricing logic
			public static Decimal pricingLogic(Decimal curr){
			    //round to .50
			    if(curr >= 0.00 && curr <= 20.00){
					System.debug('*** Default Renewal Price is < $20.00 ***');
			        	curr = roundingToDot50(curr);
			    }

			    //round to 1.00
			    if(curr >= 20.01 && curr <= 45.00){
			    		System.debug('*** Default Renewal Price is >= 20.01 && curr <= 45.00 ***');
			        	curr = roundingToDollar(curr);
			    }

			    //round to 2.00
			    if(curr >= 45.01 && curr <= 80.00){
			    		System.debug('*** Default Renewal Price is >= 45.01 && curr <= 80.00 ***');
					curr = roundingTo2Dollar(curr);
			    }

			    //round to 3.00
			    if(curr >= 80.01 && curr <= 110.00){
					System.debug('*** Default Renewal Price is >= 80.01 && curr <= 110.00 ***');
					curr = roundingTo3Dollar(curr);
			    }

			    //round to 4.00
			    if(curr >= 110.01 && curr <= 140.00){
					System.debug('*** Default Renewal Price is >= 110.01 && curr <= 140.00 ***');
					curr = roundingTo4Dollar(curr);
			    }

			    //round to 5.00
			    if(curr >= 140.01 && curr <= 200.00){
					System.debug('*** Default Renewal Price is >= 140.01 && curr <= 200.00 ***');
					curr = roundingTo5Dollar(curr);
			    }

			    //round to 10.00
			    if(curr >= 200.01 && curr <= 275.00){
					System.debug('*** Default Renewal Price is >= 200.01 && curr <= 275.00 ***');
					curr = roundingTo10Dollar(curr);
			    }

			    //round to 12.00
			    if(curr >= 275.01 && curr <= 400.00){
					System.debug('*** Default Renewal Price is >= 275.01 && curr <= 400.00 ***');
					curr = roundingTo12Dollar(curr);
			    }

			    //round to 18.00
			    if(curr >= 400.01 && curr <= 600.00){
					System.debug('*** Default Renewal Price is >= 400.01 && curr <= 600.00 ***');
					curr = roundingTo18Dollar(curr);
			    }

			    //round to 25.00
			    if(curr >= 600.01 && curr <= 800.00){
					System.debug('*** Default Renewal Price is >= 600.01 && curr <= 800.00 ***');
					curr = roundingTo25Dollar(curr);
			    }

			    //round to 35.00
			    if(curr >= 800.01){
					System.debug('*** Default Renewal Price is >= 800.01 ***');
					curr = roundingTo35Dollar(curr);
			    }

			    return curr;
			}

      //use for .50 pricing logic
      public static Decimal roundingToDot50(Decimal curr){
					System.debug('*** In roundingToDot50 ***');
          Decimal ceilNumber = curr.round(RoundingMode.CEILING) - .50;
          Decimal plusNumber = curr + 1;
          Decimal trueCeil = curr.round(RoundingMode.CEILING);

          if(curr < ceilNumber){
          	if(plusNumber > trueCeil && plusNumber - trueCeil < 1){
	          	curr = ceilNumber;
	          }
	          else if(plusNumber > trueCeil && plusNumber - trueCeil == 1){
	          	curr = plusNumber;
	          }
	          else{
	          	if(curr < ceilNumber){
	                curr = ceilNumber;
		          }
		          else{
		          		curr = curr.round(RoundingMode.CEILING);
		          }
	          }//end of outter else
          }
          else{
          	if(plusNumber > trueCeil && plusNumber - trueCeil == 1){
          		curr = trueCeil + .50;
          	}
          	else{
          		curr = trueCeil;
          	}

          }

          System.debug('*** curr *** ' + curr );
          return curr;
      }//end of public static decimal

			//Logic to round to nearest dollar (always up)
		public static Decimal roundingToDollar(Decimal curr){
				System.debug('*** In roundingToDollar ***');
				Decimal currDeci;
				Decimal ceilNumber = curr.round(RoundingMode.CEILING);
		    Decimal plusNumber = curr + 1;

				if(curr == ceilNumber ){
					currDeci = plusNumber;
				}
				else{
					currDeci = curr.round(RoundingMode.CEILING);
				}

		    return currDeci;
	  }//end of public static double

     //Logic to round to nearest dollar (always up)
		public static Decimal roundingTo2Dollar(Decimal curr){
				System.debug('*** In roundingToDollar ***');
		          System.debug('*** curr *** ' + curr.round(RoundingMode.CEILING) );
				Decimal currDeci;
				Decimal ceilNumber = curr.round(RoundingMode.CEILING);
		          Decimal plusNumber = curr + 1;

				if(curr == ceilNumber ){
					currDeci = plusNumber + 1;
				}
				else{
					currDeci = curr.round(RoundingMode.CEILING) + 1;
				}

		    return currDeci;
	  }//end of public static double

      //Logic to round to nearest dollar (always up)
		public static Decimal roundingTo3Dollar(Decimal curr){
				System.debug('*** In roundingToDollar ***');
		          System.debug('*** curr *** ' + curr.round(RoundingMode.CEILING) );
		          Decimal currDeci;
				Decimal ceilNumber = curr.round(RoundingMode.CEILING);
		          Decimal plusNumber = curr + 1;

				if(curr == ceilNumber ){
					currDeci = plusNumber + 2;
				}
				else{
					currDeci = curr.round(RoundingMode.CEILING) + 2;
				}

	      return currDeci;
	  }//end of public static double

      //Logic to round to nearest dollar (always up)
		public static Decimal roundingTo4Dollar(Decimal curr){
				System.debug('*** In roundingToDollar ***');
		          System.debug('*** curr *** ' + curr.round(RoundingMode.CEILING) );
				Decimal currDeci;
				Decimal ceilNumber = curr.round(RoundingMode.CEILING);
		          Decimal plusNumber = curr + 1;

				if(curr == ceilNumber ){
					currDeci = plusNumber + 3;
				}
				else{
					currDeci = curr.round(RoundingMode.CEILING) + 3;
				}

	      return currDeci;
	  }//end of public static double

      //Logic to round to nearest dollar (always up)
		public static Decimal roundingTo5Dollar(Decimal curr){
				System.debug('*** In roundingToDollar ***');
		          System.debug('*** curr *** ' + curr.round(RoundingMode.CEILING) );
				Decimal currDeci;
				Decimal ceilNumber = curr.round(RoundingMode.CEILING);
		          Decimal plusNumber = curr + 1;

				if(curr == ceilNumber ){
					currDeci = plusNumber + 4;
				}
				else{
					currDeci = curr.round(RoundingMode.CEILING) + 4;
				}

	      return currDeci;
	 	}//end of public static double

      //Logic to round to nearest dollar (always up)
		public static Decimal roundingTo10Dollar(Decimal curr){
				System.debug('*** In roundingToDollar ***');
		          System.debug('*** curr *** ' + curr.round(RoundingMode.CEILING) );
		          Decimal currDeci;
				Decimal ceilNumber = curr.round(RoundingMode.CEILING);
		          Decimal plusNumber = curr + 1;

				if(curr == ceilNumber ){
					currDeci = plusNumber + 9;
				}
				else{
					currDeci = curr.round(RoundingMode.CEILING) + 9;
				}

		    return currDeci;
	  }//end of public static double

      //Logic to round to nearest dollar (always up)
	public static Decimal roundingTo12Dollar(Decimal curr){
		System.debug('*** In roundingToDollar ***');
          System.debug('*** curr *** ' + curr.round(RoundingMode.CEILING) );
		Decimal currDeci;
		Decimal ceilNumber = curr.round(RoundingMode.CEILING);
          Decimal plusNumber = curr + 1;

		if(curr == ceilNumber ){
			currDeci = plusNumber + 11;
		}
		else{
			currDeci = curr.round(RoundingMode.CEILING) + 11;
		}
          //System.debug('*** curr *** ' + curr.round(RoundingMode.CEILING) );

          return currDeci;
      }//end of public static double

      //Logic to round to nearest dollar (always up)
		public static Decimal roundingTo18Dollar(Decimal curr){
				System.debug('*** In roundingToDollar ***');
		          System.debug('*** curr *** ' + curr.round(RoundingMode.CEILING) );
				Decimal currDeci;
				Decimal ceilNumber = curr.round(RoundingMode.CEILING);
		          Decimal plusNumber = curr + 1;

				if(curr == ceilNumber ){
					currDeci = plusNumber + 17;
				}
				else{
					currDeci = curr.round(RoundingMode.CEILING) + 17;
				}

	      return currDeci;
	  }//end of public static double

      //Logic to round to nearest dollar (always up)
		public static Decimal roundingTo25Dollar(Decimal curr){
				System.debug('*** In roundingToDollar ***');
		    System.debug('*** curr *** ' + curr.round(RoundingMode.CEILING) );
				Decimal currDeci;
				Decimal ceilNumber = curr.round(RoundingMode.CEILING);
		    Decimal plusNumber = curr + 1;

				if(curr == ceilNumber ){
					currDeci = plusNumber + 24;
				}
				else{
					currDeci = curr.round(RoundingMode.CEILING) + 24;
				}
	      //System.debug('*** curr *** ' + curr.round(RoundingMode.CEILING) );

	      return currDeci;
	  }//end of public static double

      //Logic to round to nearest dollar (always up)
		public static Decimal roundingTo35Dollar(Decimal curr){
				System.debug('*** In roundingToDollar ***');
		    System.debug('*** curr *** ' + curr.round(RoundingMode.CEILING) );
				Decimal currDeci;
				Decimal ceilNumber = curr.round(RoundingMode.CEILING);
		    Decimal plusNumber = curr + 1;

				if(curr == ceilNumber ){
					currDeci = plusNumber + 34;
				}
				else{
					currDeci = curr.round(RoundingMode.CEILING) + 34;
				}
	      //System.debug('*** curr *** ' + curr.round(RoundingMode.CEILING) );

	      return currDeci;
	  }//end of public static double

		//logic for Anesthesia Airways Products
		public static Decimal airwaysPricing(Decimal curr){
				return (curr * 0.03) + curr;
		}//end of airwaysPricing

		//logic for Anesthesia Regional Anesthesia Products
		public static Decimal regionalAnesPricing(Decimal curr){
				return (curr * 0.04) + curr;
		}//end of regionalAnesPricing

		//logic for Anesthesia Regional Anesthesia Products
		public static Decimal madLmaPricing(Decimal curr){
				return (curr * 0.04) + curr;
		}//end of madLmaPricing

		//logic for Surgical Products
		public static Decimal accessClosure(Decimal curr){
				return (curr * 0.02) + curr;
		}//end of accessClosure

		//logic for Surgical Products
		public static Decimal autoPolymer(Decimal curr){
			//check price... if $390 leave be
			if(curr != 390.00){
				return (curr * 0.04) + curr;
			}
			else{
				return curr;
			}
		}//end of autoPolymer

		//logic for Surgical Products
		public static Decimal cholangiography(Decimal curr){
				Decimal currDeci;
				Decimal ceilNumber = curr.round(RoundingMode.CEILING);
				Decimal plusNumber = curr + 1;

				if(curr == ceilNumber ){
					currDeci = (plusNumber * .06) + plusNumber;
				}
				else{
					currDeci = (ceilNumber * .06) + ceilNumber;
				}

				return currDeci;
		}//end of Cholangiography

		//logic for Surgical Products
		public static Decimal conHarvesting(Decimal curr){
				Decimal currDeci;
				Decimal ceilNumber = curr.round(RoundingMode.CEILING);
				Decimal plusNumber = curr + 1;

				if(curr == ceilNumber ){
					currDeci = (plusNumber * .09) + plusNumber;
				}
				else{
					currDeci = (ceilNumber * .09) + ceilNumber;
				}

				return currDeci;
		}//end of conHarvesting

		//Metal Clip Remov.Forcep 10.5 products
		public static Decimal metalClip105(Decimal curr){
				//set to $99.00
				curr = 199.00;
				return curr;
		}

		//Metal Clip Remov.Forcep 6.5 products
		public static Decimal metalClip65(Decimal curr){
				//set to $99.00
				curr = 199.00;
				return curr;
		}

		//miniLap products
		public static Decimal miniLap(Decimal curr){
				//set to $415.00
				return (curr * 0.025) + curr;
		}

		//percuvance products
		public static Decimal percuvance(Decimal curr){
				//set to $415.00
				return (curr * 0.025) + curr;
		}

		//logic for Surgical Products
		public static Decimal skinStapling(Decimal curr){
				Decimal currDeci;
				Decimal ceilNumber = curr.round(RoundingMode.CEILING);
				Decimal plusNumber = curr + 1;

				if(curr == ceilNumber ){
					currDeci = plusNumber;
				}
				else{
					currDeci = curr.round(RoundingMode.CEILING);
				}

				return currDeci;
		}//end of skinStapling

		//sterility storage tray
		public static Decimal sterStorageTray(Decimal curr){
				//set to $415.00
				curr = 415.00;
				return curr;
		}

		//Surgical MemoBag
		public static Decimal memobag(Decimal curr){
				Decimal currDeci;
				currDeci = (curr * .025) + curr;
				return currDeci;
		}

		//metal open appliers
		public static Decimal metalAppliers(Decimal curr){
				//set to $415.00
				curr = 99.00;
				return curr;
		}

		//10% increase, round up to nearest whole dollar
		public static Decimal trocars(Decimal curr){
			Decimal currDeci;
			Decimal ceilNumber = curr.round(RoundingMode.CEILING);
			Decimal plusNumber = curr + 1;

			if(curr == ceilNumber ){
				currDeci = (plusNumber * .10) + plusNumber;
			}
			else{
				currDeci = (ceilNumber * .10) + ceilNumber;
			}

			return currDeci;
		}

		/********************* Vascular Pricing Logic *********************************/
		//4% increase, round up to nearest whole dollar
		public static Decimal vascularProds(Decimal curr){
			Decimal currDeci;
			Decimal ceilNumber = curr.round(RoundingMode.CEILING);
			Decimal plusNumber = curr + 1;

			if(curr == ceilNumber ){
				currDeci = (plusNumber * .04) + plusNumber;
			}
			else{
				currDeci = (ceilNumber * .04) + ceilNumber;
			}

			return currDeci;
		}
		/********************* Vascular Pricing Logic *********************************/

		/********************* Interventional Pricing Logic *********************************/
		//4% increase, round up to nearest whole dollar
		public static Decimal interventionalProds(Decimal curr){
			Decimal currDeci;

			currDeci = (curr * .04) + curr;
			return currDeci;
		}
		/********************* Interventional Pricing Logic *********************************/
}//end of class